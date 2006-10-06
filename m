From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 06 Oct 2006 15:18:33 -0400
Message-ID: <4526AC09.4040804@garzik.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <20061006110317.0c6c1f98@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	Val Henson <val_henson@linux.intel.com>,
	netdev@vger.kernel.org, Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:18856 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422685AbWJFTSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 15:18:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061006110317.0c6c1f98@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 06 Oct 2006 12:12:34 -0600
> Matthew Wilcox <matthew@wil.cx> wrote:
> 
>> From: Helge Deller <deller@parisc-linux.org>
>>
>> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
>> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)
> 
> This is caused because with PCI hotplug the device might be probed after the init section
> has been removed.  Ditto for remove.

This device will never ever meet a platform where it can be hotplugged.

	Jeff



