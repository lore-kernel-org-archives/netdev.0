From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 6 Oct 2006 13:25:52 -0600
Message-ID: <20061006192552.GM2563@parisc-linux.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <20061006110317.0c6c1f98@freekitty> <4526AC09.4040804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Val Henson <val_henson@linux.intel.com>,
	netdev@vger.kernel.org, Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:10406 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S932458AbWJFTZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 15:25:53 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4526AC09.4040804@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2006 at 03:18:33PM -0400, Jeff Garzik wrote:
> Stephen Hemminger wrote:
> >On Fri, 06 Oct 2006 12:12:34 -0600
> >Matthew Wilcox <matthew@wil.cx> wrote:
> >
> >>From: Helge Deller <deller@parisc-linux.org>
> >>
> >>WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to 
> >>.init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 
> >>0x20)
> >>WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to 
> >>.exit.text:de_remove_one from .data.rel.local after 'de_driver' (at 
> >>offset 0x28)
> >
> >This is caused because with PCI hotplug the device might be probed after 
> >the init section
> >has been removed.  Ditto for remove.
> 
> This device will never ever meet a platform where it can be hotplugged.

According to a FreeBSD list from 1995, you could get these chips on a PCI
card from several different vendors.

http://docs.freebsd.org/cgi/getmsg.cgi?fetch=37148+0+archive/1995/freebsd-hardware/19951001.freebsd-hardware
