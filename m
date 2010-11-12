From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Sat, 13 Nov 2010 00:40:27 +0200
Message-ID: <20101112224026.GA21134@core2.telecom.by>
References: <1289546610.17691.1770.camel@edumazet-laptop>
 <20101112083315.096dfaa3@nehalam>
 <20101112201850.GA5625@core2.telecom.by>
 <20101112.123738.179940542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:50238 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147Ab0KLWkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 17:40:32 -0500
Received: by ewy8 with SMTP id 8so21600ewy.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 14:40:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101112.123738.179940542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 12:37:38PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Fri, 12 Nov 2010 22:18:50 +0200
> 
> > On Fri, Nov 12, 2010 at 08:33:15AM -0800, Stephen Hemminger wrote:
> >> Also, the whole idea needs to be under a config option, so only
> >> the paranoid idiots turn it on.
> > 
> > Would be fun if something will break because ffff8800bcd498c0
> > will become something else. :-)
> 
> Actually, this is not even a joke.
> 
> Take a look at how we track what sockets a user wants dumped via
> the inet_diag netlink facility, the socket pointer is used as
> the identification cookie.

I think we should not expose kernel pointers in future interfaces,
but leave existing ones alone.
