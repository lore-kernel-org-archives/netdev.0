From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
 entry memories when vector allocation fails
Date: Mon, 29 Oct 2007 05:55:44 -0400
Message-ID: <4725AE20.7000400@garzik.org>
References: <Pine.GSO.4.10.10710280403250.29009-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34412 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbXJ2Jzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:55:48 -0400
In-Reply-To: <Pine.GSO.4.10.10710280403250.29009-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sivakumar Subramani wrote:
> - Fixed memory leak by freeing MSI-X local entry memories when vector allocation
> fails in s2io_add_isr.
> - Added two utility functions do_rem_msix_isr and do_rem_inta_isr to eliminate
> code duplication.
> 
> Signed-off-by: Veena Parat <veena.parat@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>

Comments:

1) stats->mem_freed is redundant to general kernel debugging facilities

2) synchronize_irq() is redundant, free_irq() does same

3) "rem" isn't very clear.  few if any other kernel drivers use this to 
indicate "remove"

4) "do_" prefix is redundant

5) scripts/checkpatch.pl fails on this patch.  please clean up problems.

The main issue for this patch is #2, though presumably the other stuff 
can be cleaned on the next resubmit


