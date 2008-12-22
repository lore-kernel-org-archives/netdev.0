From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bug #12261] kernel panics with net_rx_action on kernels above 2.6.26
Date: Mon, 22 Dec 2008 21:26:41 +0100
Message-ID: <200812222126.41727.rjw@sisk.pl>
References: <_EB9bLpq_z.A.hAC.NkYTJB@chimera> <CMMRhk39O-L.A.tMC.TkYTJB@chimera> <20081222072614.GB2631@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Alexander Huemer <alexander.huemer@sbg.ac.at>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:55645 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175AbYLVU0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2008 15:26:32 -0500
In-Reply-To: <20081222072614.GB2631@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 22 of December 2008, Jarek Poplawski wrote:
> On Sat, Dec 20, 2008 at 11:16:15PM +0100, Rafael J. Wysocki wrote:
> > This message has been generated automatically as a part of a report
> > of regressions introduced between 2.6.26 and 2.6.27.
> > 
> > The following bug entry is on the current list of known regressions
> > introduced between 2.6.26 and 2.6.27.  Please verify if it still should
> > be listed and let me know (either way).
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12261
> > Subject		: kernel panics with net_rx_action on kernels above 2.6.26
> > Submitter	: Alexander Huemer <alexander.huemer@sbg.ac.at>
> > Date		: 2008-12-13 18:43 (8 days old)
> > References	: http://marc.info/?l=linux-kernel&m=122919424932016&w=4
> > Handled-By	: Jarek Poplawski <jarkao2@gmail.com>
> > Patch		: http://marc.info/?l=linux-net&m=122934825227768&w=4
> > 
> > 
> 
> It's fixed in the mainline:
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=9a3de25544dadab1971847f28f33b1cd0d1770a6
> 
> But stables need this too:
> - 2.6.27 - always
> - 2.6.26, 2.6.25 (...?) for CONFIG_ADAPTEC_STARFIRE_NAPI

Thanks, I've just pushed inclusion request to -stable.

Rafael
