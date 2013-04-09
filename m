From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: enable features before registering the driver
Date: Tue, 9 Apr 2013 07:46:00 +0200
Message-ID: <20130409054600.GA31821@1wt.eu>
References: <20130406184701.GA16142@1wt.eu> <20130408.121604.421731991206410747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:46526 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205Ab3DIFqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 01:46:11 -0400
Content-Disposition: inline
In-Reply-To: <20130408.121604.421731991206410747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 12:16:04PM -0400, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 6 Apr 2013 20:47:01 +0200
> 
> > Hi,
> > 
> > I noticed that mvneta's tx-csum/sg were off until disabled then
> > enabled, which led me to think that something was not made in the
> > correct sequence. And indeed, setting the dev features _before_
> > registering the device works much better :-)
> > 
> > This patch is for master but may be backported to 3.8-stable as well,
> > which is where I first experienced the issue.
> 
> Please don't post patches like this, you make extra work for the
> maintainer by having to edit out this commentary.
> 
> You put such commentary after the "---" seperator the delineates
> your commit message in the email body, not before.

Sorry for this David, I'll take care of this next time.

> Anyways, applied.

Thank you.

Willy
