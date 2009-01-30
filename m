From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 18:13:06 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901301811530.4994@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901300110.56533.rjw@sisk.pl> <alpine.DEB.2.00.0901301730230.6574@parag-desktop> <200901302354.27497.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.187]:33320 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597AbZA3XNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:13:17 -0500
In-Reply-To: <200901302354.27497.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:

> On Friday 30 January 2009, Parag Warudkar wrote:
> > 
> > On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:
> > 
> > > 
> > > I still am interested if it makes any difference for Parag.
> > 
> > No difference - tg3 is still dead after resume.
> 
> Thanks for testing.
> 
> Well, I'm not sure if tg3 is at fault, really.
> 
> What happens if you unload tg3 before suspend and load it back after the
> resume?

This time it fails with different error on loading after suspend/resume 
cycle -

 1196.873608] tg3 0000:0e:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[ 1196.873620] tg3 0000:0e:00.0: setting latency timer to 64
[ 1196.880017] tg3 0000:0e:00.0: PME# disabled
[ 1196.996270] tg3: (0000:0e:00.0) phy probe failed, err -19
[ 1197.508033] tg3: Problem fetching invariants of chip, aborting.
[ 1197.508048] tg3 0000:0e:00.0: PCI INT A disabled
 
Parag
