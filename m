From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 6 Oct 2006 13:54:47 -0600
Message-ID: <20061006195447.GQ2563@parisc-linux.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <20061006110317.0c6c1f98@freekitty> <4526AC09.4040804@garzik.org> <20061006192552.GM2563@parisc-linux.org> <4526B21E.8060408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Val Henson <val_henson@linux.intel.com>,
	netdev@vger.kernel.org, Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:47579 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S932354AbWJFTys (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 15:54:48 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4526B21E.8060408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2006 at 03:44:30PM -0400, Jeff Garzik wrote:
> Matthew Wilcox wrote:
> >On Fri, Oct 06, 2006 at 03:18:33PM -0400, Jeff Garzik wrote:
> >>This device will never ever meet a platform where it can be hotplugged.
> >
> >According to a FreeBSD list from 1995, you could get these chips on a PCI
> >card from several different vendors.
> >
> 
> Yes, they are ancient 32-bit PCI cards, which will never make an 
> appearance on a PCI hotplug platform.  So, it's wasteful to support 
> hotplug in code that will never be hotplugged (as I've said for years).

Sorry, you're saying that anyone who has found one of these cards and
wants to plug them into a hotplug slot in their shiny new server is just
SOL?  That makes no sense, Jeff.  We've fixed *so* many old drivers to
confirm to these rules, why's this one so special?  I'd understand if it
were only found on motherboards, but it can be found on cards.

Plus it silences a warning.  Isn't that enough reason of its own?
