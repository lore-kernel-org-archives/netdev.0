From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 06 Oct 2006 16:11:25 -0400
Message-ID: <4526B86D.2080307@garzik.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <20061006110317.0c6c1f98@freekitty> <4526AC09.4040804@garzik.org> <20061006192552.GM2563@parisc-linux.org> <4526B21E.8060408@garzik.org> <20061006195447.GQ2563@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Val Henson <val_henson@linux.intel.com>,
	netdev@vger.kernel.org, Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49577 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932563AbWJFULf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 16:11:35 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061006195447.GQ2563@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Oct 06, 2006 at 03:44:30PM -0400, Jeff Garzik wrote:
>> Matthew Wilcox wrote:
>>> On Fri, Oct 06, 2006 at 03:18:33PM -0400, Jeff Garzik wrote:
>>>> This device will never ever meet a platform where it can be hotplugged.
>>> According to a FreeBSD list from 1995, you could get these chips on a PCI
>>> card from several different vendors.
>>>
>> Yes, they are ancient 32-bit PCI cards, which will never make an 
>> appearance on a PCI hotplug platform.  So, it's wasteful to support 
>> hotplug in code that will never be hotplugged (as I've said for years).
> 
> Sorry, you're saying that anyone who has found one of these cards and
> wants to plug them into a hotplug slot in their shiny new server is just
> SOL?  That makes no sense, Jeff.  We've fixed *so* many old drivers to
> confirm to these rules, why's this one so special?  I'd understand if it
> were only found on motherboards, but it can be found on cards.
> 
> Plus it silences a warning.  Isn't that enough reason of its own?

Early tulips were electrically "special", so I am highly doubtful it 
would work in any case.

But overall it doesn't make sense to me to force code to exist, that we 
know will likely never ever be needed.

Whatever.  This patch comes up every year or two, so I suppose I should 
just quit fighting and eat the needless code size increase, to silence 
the human warnings :)

	Jeff



