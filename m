From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH] net: Fix oops in dev_ifsioc()
Date: Fri, 19 Dec 2008 09:33:01 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812190929180.934@ask.diku.dk>
References: <20081219070431.GA7189@ff.dom.local> <494B552B.1010602@cn.fujitsu.com>
 <20081219081104.GB7189@ff.dom.local> <494B57FE.3070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:54727 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbYLSIdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 03:33:05 -0500
In-Reply-To: <494B57FE.3070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2008, Wang Chen wrote:

> Jarek Poplawski said the following on 2008-12-19 16:11:
> > On Fri, Dec 19, 2008 at 04:02:51PM +0800, Wang Chen wrote:
> >> Jarek Poplawski said the following on 2008-12-19 15:04:
> >>> A command like this: "brctl addif br1 eth1" issued as a user gave me
> >>> an oops when bridge module wasn't loaded. It's caused by using a dev
> >>> pointer before checking for NULL.
> > ...
> >> Subject will be changed, sorry.
> >> Seems Julia  is doing "Move a dereference below a NULL test" check,
> >> but why the coccinelle missed this one?
> > 
> > Probably because it's quite fresh?
> > 
> 
> Yes. Maybe Julia never check the source of -next. :)

Sorry, my -next was mysteriously quite out of date.  It's up to date now.
Indeed, I found that one just now.

julia
