From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 06 Oct 2006 14:39:41 -0400
Message-ID: <4526A2ED.6030406@garzik.org>
References: <11601583542790-git-send-email-matthew@wil.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>, netdev@vger.kernel.org,
	Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:6822 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422831AbWJFSjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 14:39:48 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <11601583542790-git-send-email-matthew@wil.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> From: Helge Deller <deller@parisc-linux.org>
> 
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)

I'm a bit blind, so help me out here...  what precisely is mismatched?

AFAICS everything is properly marked __init or __exit.

	Jeff



