From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb and UDP packages bigger than 1500
Date: Tue, 11 Dec 2007 09:36:00 +0100
Message-ID: <20071211083559.GB2261@ff.dom.local>
References: <20071211081929.GA2261@ff.dom.local> <200712110917.30945.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:36697 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbXLKIbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 03:31:01 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1221906nfb
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 00:30:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200712110917.30945.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 09:17:30AM +0100, Arkadiusz Miskiewicz wrote:
> On Tuesday 11 of December 2007, Jarek Poplawski wrote:
> > On 10-12-2007 18:10, Arkadiusz Miskiewicz wrote:
> > > Hello,
> > >
> > > I noticed that HTB doesn't properly limit traffic if someone sends UDP
> > > packages bigger than 1500.
> > >
> > > Does HTB have some problems/known limits in this area?
> > >
> > > There is other traffic in that class and when I drop udp packets bigger
> > > than 1500 then remaining traffic is limited properly to correct value.
> >
> > Should work with proper "mtu" parameter (tc qdisc add htb help) or,
> > for kernels >= 2.6.23, even without this. If this doesn't help,
> > probably more information is required.
> 
> 2.6.22 there. mtu wasn't specified at tc... Could you point to a git commit 
> which "fixes" the issue in 2.6.23 so I could backport it to my 2.6.22?

http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.23.y.git;a=commitdiff;h=c9726d6890f7f3a892c879e067c3ed839f61e745

From: Ranjit Manomohan <ranjitm@google.com>
Date: Wed, 11 Jul 2007 05:43:16 +0000 (-0700)
Subject: [NET_SCHED]: Make HTB scheduler work with TSO.
X-Git-Tag: v2.6.23-rc1~1109^2~22

But this is done with two different ways. And btw., if there is such
a big difference in sizes it could be not very accurate after all.

Jarek P.
