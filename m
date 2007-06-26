From: Luca <kronos.it@gmail.com>
Subject: Re: [PATCH] atl1: disable 64bit DMA
Date: Tue, 26 Jun 2007 23:12:44 +0200
Message-ID: <68676e00706261412q3ed671bdg4246d6702d70abde@mail.gmail.com>
References: <467B12CA.5060405@esuna.co.uk>
	 <20070624164519.04f215b8@osprey.hogchain.net>
	 <467FB237.2030703@esuna.co.uk> <467FB844.6060702@bellsouth.net>
	 <20070625211855.GA19275@dreamland.darkstar.lan>
	 <46803557.50805@redhat.com> <468038FC.6090302@esuna.co.uk>
	 <46803A40.4070009@redhat.com>
	 <20070625180039.4f083846@osprey.hogchain.net>
	 <46804CFC.4000702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jay Cliburn" <jacliburn@bellsouth.net>,
	"Chris Snook" <csnook@redhat.com>,
	"Jay L. T. Cornwall" <jay@esuna.co.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:20316 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756075AbXFZVMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 17:12:45 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1848238nzf
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2007 14:12:44 -0700 (PDT)
In-Reply-To: <46804CFC.4000702@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/26/07, Jeff Garzik <jgarzik@pobox.com> wrote:
> Jay Cliburn wrote:
> > On Mon, 25 Jun 2007 17:57:20 -0400
> > Chris Snook <csnook@redhat.com> wrote:
> >
> >> Jay L. T. Cornwall wrote:
> >>> Chris Snook wrote:
> >>>
> >>>> What boards have we seen this on?  It's quite possible this is:
> >>> I can reproduce on an Asus P5K with a Core 2 Duo E6600.
> >>>
> >>> lspci identifies the controller as:
> >>>   02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
> >>>   Ethernet Adapter (rev b0)
> >>>
> >>> dmesg notes the PCI-DMA mapping implementation:
> >>>   PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
> >>>
> >> I had a hunch this was on Intel.  I'd rather just disable this when
> >> swiotlb is in use, unless we get more complaints.  It's probably
> >> ultimately a BIOS quirk anyway.
> >
> > So far we have reports from both camps:
> >
> > Asus M2N8-VMX (AM2):  1 report of lockup
> > http://sourceforge.net/mailarchive/forum.php?thread_name=46780384.063603.26165%40m12-15.163.com&forum_name=atl1-devel
> >
> > Asus P5K (LGA775):    2 reports of lockups
> > http://sourceforge.net/mailarchive/forum.php?thread_name=467E7E34.4010603%40gmail.com&forum_name=atl1-devel
> > http://lkml.org/lkml/2007/6/25/107
> >
> > The common denominator in these reports is 4GB RAM.
>
> Although its possible this device doesn't really support 64-bit, it's
> more likely that this is a platform problem of some sort, or a driver
> bug of some sort.  In the driver, maybe it has a problem when you
> -cross- a 4GB boundary, which is not uncommon.

I don't follow you :| What kind "common" mistakes should we check for
in the driver?

Luca
