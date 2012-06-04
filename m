From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Remove casts to same type
Date: Mon, 04 Jun 2012 08:52:08 -0700
Message-ID: <1338825128.8574.15.camel@joe2Laptop>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
	 <20120604.114533.1720204611284591292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55794 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754056Ab2FDPwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 11:52:09 -0400
In-Reply-To: <20120604.114533.1720204611284591292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 11:45 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> > Adding casts of objects to the same type is unnecessary
> > and confusing for a human reader.
[]
> > I used the coccinelle script below to find and remove these
> > unnecessary casts.  I manually removed the conversions this
> > script produces of casts with __force and __user.
> > 
> > @@
> > type T;
> > T *p;
> > @@
> > 
> > -	(T *)p
> > +	p
> Applied to net-next, thanks Joe.

Do you want the same thing for drivers/net?

It's pretty big and might be better broken into
commits by maintainer/directory.
