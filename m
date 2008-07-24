From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/4] sky2: Adapt sky2 to use reworked PCI PM
Date: Thu, 24 Jul 2008 13:59:33 -0700
Message-ID: <20080724135933.71d3572c@extreme>
References: <200807191436.40726.rjw@sisk.pl>
	<200807191442.52759.rjw@sisk.pl>
	<20080720190742.84258d7e.akpm@linux-foundation.org>
	<200807242250.51119.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:45259 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbYGXU7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 16:59:36 -0400
In-Reply-To: <200807242250.51119.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 22:50:50 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> [Sorry for the delayed response, I'm at OLS.]
> 
> On Monday, 21 of July 2008, Andrew Morton wrote:
> > On Sat, 19 Jul 2008 14:42:51 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > 
> > > Adapt the sky2 driver to use the reworked PCI PM.
> > 
> > I fixed the rejects in "[PATCH 3/4] tg3: Adapt tg3 to use reworked PCI
> > PM code" but this patch has too many for me to want to fix them.
> > 
> > As usual, please at least take a look at what's in linux-next before
> > going and bypassing all that queued work.
> 
> Sorry for that.
> 
> Appended is a version of the patch applying to the current mainline on top of
> patches 1/4 - 3/4 without rejects.
> 
> BTW, the sky2's WOL is broken on my test box because of commit
> db99b98885e717454feef1c6868b27d3f23c2e7c ("sky2: put PHY in sleep when down")
> that causes the box to hang solid in sky2_suspend() and sky2_shutdown() after
> WOL has been enabled with 'ethtool -s eth0 wol g'.
> 
> This has already been reported to Stephen and Jeff.
> 
> Thanks,
> Rafael

Please wait, I am working on a better stable way to do this.
