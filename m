From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/9] [TULIP] Fix section mismatch in de2104x.c
Date: Wed, 09 Aug 2006 01:37:35 -0400
Message-ID: <44D9749F.8040206@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org> <11549840343640-git-send-email-kyle@parisc-linux.org> <11549840351899-git-send-email-kyle@parisc-linux.org> <11549840361794-git-send-email-kyle@parisc-linux.org> <11549840363242-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org,
	Helge Deller <deller@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:15008 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965075AbWHIFhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:37:37 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <11549840363242-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Helge Deller <deller@parisc-linux.org>
> 
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 0x20)
> WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to .exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 0x28)
> 
> Signed-off-by: Helge Deller <deller@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>

Look deeper into the problem...  Use of __init and __exit was 
intentional, as this card is never used in a hotplug situation AFAIK


