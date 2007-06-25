From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] atl1: disable 64bit DMA
Date: Mon, 25 Jun 2007 18:00:39 -0500
Message-ID: <20070625180039.4f083846@osprey.hogchain.net>
References: <467B12CA.5060405@esuna.co.uk>
	<467BE118.4090308@redhat.com>
	<467BE4F1.7040308@esuna.co.uk>
	<467D0EB0.9030100@esuna.co.uk>
	<20070624125957.2e27820c@osprey.hogchain.net>
	<467ED4A8.4080500@esuna.co.uk>
	<20070624164519.04f215b8@osprey.hogchain.net>
	<467FB237.2030703@esuna.co.uk>
	<467FB844.6060702@bellsouth.net>
	<20070625211855.GA19275@dreamland.darkstar.lan>
	<46803557.50805@redhat.com>
	<468038FC.6090302@esuna.co.uk>
	<46803A40.4070009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jay L. T. Cornwall" <jay@esuna.co.uk>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf22aec.mail.bellsouth.net ([205.152.59.70]:34823 "EHLO
	imf22aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922AbXFZACy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 20:02:54 -0400
In-Reply-To: <46803A40.4070009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jun 2007 17:57:20 -0400
Chris Snook <csnook@redhat.com> wrote:

> Jay L. T. Cornwall wrote:
> > Chris Snook wrote:
> > 
> >> What boards have we seen this on?  It's quite possible this is:
> > 
> > I can reproduce on an Asus P5K with a Core 2 Duo E6600.
> > 
> > lspci identifies the controller as:
> >   02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
> >   Ethernet Adapter (rev b0)
> > 
> > dmesg notes the PCI-DMA mapping implementation:
> >   PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> > 
> 
> I had a hunch this was on Intel.  I'd rather just disable this when
> swiotlb is in use, unless we get more complaints.  It's probably
> ultimately a BIOS quirk anyway.

So far we have reports from both camps:

Asus M2N8-VMX (AM2):	1 report of lockup
http://sourceforge.net/mailarchive/forum.php?thread_name=46780384.063603.26165%40m12-15.163.com&forum_name=atl1-devel

Asus P5K (LGA775):	2 reports of lockups
http://sourceforge.net/mailarchive/forum.php?thread_name=467E7E34.4010603%40gmail.com&forum_name=atl1-devel
http://lkml.org/lkml/2007/6/25/107

The common denominator in these reports is 4GB RAM.
