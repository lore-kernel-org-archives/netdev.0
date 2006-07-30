From: Andrew Morton <akpm@osdl.org>
Subject: Re: [parisc-linux] [git patches] tulip fixes from parisc-linux
Date: Sun, 30 Jul 2006 11:35:32 -0700
Message-ID: <20060730113532.4db2fcb5.akpm@osdl.org>
References: <20060729225459.GA4835@athena.road.mcmartin.ca>
	<20060730004339.GC11975@colo.lackof.org>
	<20060730165607.GB4835@athena.road.mcmartin.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	netdev@vger.kernel.org, parisc-linux@lists.parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51433 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932421AbWG3Sfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 14:35:36 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <20060730165607.GB4835@athena.road.mcmartin.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Jul 2006 12:56:07 -0400
Kyle McMartin <kyle@parisc-linux.org> wrote:

> On Sat, Jul 29, 2006 at 06:43:39PM -0600, Grant Grundler wrote:
> > I just wanted to warn that some of the changes are already in akpm
> > 's tree (-mm).
> > Becuase off hand I've forgotten which ones, would it be better to
> > diff against -mm instead?
> 
> tulip-fix-shutdown-dma-irq-race.patch
>   tulip: fix shutdown DMA/irq race
> 
> tulip-fix-for-64-bit-mips.patch
>   tulip: fix for 64-bit mips
> 
> tulip-natsemi-dp83840a-phy-fix.patch
>   tulip: NatSemi DP83840A PHY fix
> 
> Are the tulip patches in -mm, found here:
> http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-fix-for-64-bit-mips.patch
> http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-fix-shutdown-dma-irq-race.patch
> http://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/tulip-natsemi-dp83840a-phy-fix.patch
> 
> [akpm: I added you to the CC list, if Val acks the patches can
> you see that they make their way into -mm?
> git.kernel.org/pub/scm/linux/kernel/git/kyle/tulip-2.6.git#master]
> 

hm.  A couple of those patches have been futzing around in -mm for over a
year and have been nacked by Jeff and are a regular source of grumpygrams. 
I've been sitting on them in the pathetic hope that someone will one day
get down and address the bugs which they fix in an acceptable fashion,
whatever that is.

