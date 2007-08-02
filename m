From: Michael Buesch <mb@bu3sch.de>
Subject: Re: b44 compile error on !PCI
Date: Thu, 2 Aug 2007 19:17:45 +0200
Message-ID: <200708021917.45876.mb@bu3sch.de>
References: <Pine.SOC.4.64.0708021943510.7589@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46186
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052AbXHBRRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 13:17:48 -0400
In-Reply-To: <Pine.SOC.4.64.0708021943510.7589@math.ut.ee>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 August 2007, Meelis Roos wrote:
> Tryng to compile todays git on SBus-only Sparc64 (Ultra 1), no PCI. b44 
> is selectable but fails to compile:
> 
>   CC [M]  drivers/net/b44.o
> drivers/net/b44.c: In function 'b44_sync_dma_desc_for_device':
> drivers/net/b44.c:134: error: implicit declaration of function 'dma_sync_single_range_for_device'
> drivers/net/b44.c: In function 'b44_sync_dma_desc_for_cpu':
> drivers/net/b44.c:144: error: implicit declaration of function 'dma_sync_single_range_for_cpu'

Are you sure this is related to !PCI ?
If I grep include/asm-sparc64/dma-mapping.h I don't
find dma_sync_single_range_for_*
So I'd rather call this a bug in the arch code of sparc64.
