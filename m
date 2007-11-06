From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
 entry memories when vector allocation fails
Date: Tue, 06 Nov 2007 12:46:26 -0500
Message-ID: <4730A872.6030801@garzik.org>
References: <Pine.GSO.4.10.10710310408190.9897-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35966 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578AbXKFRqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 12:46:44 -0500
In-Reply-To: <Pine.GSO.4.10.10710310408190.9897-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sreenivasa Honnur wrote:
> - Fixed memory leak by freeing MSI-X local entry memories when vector allocation
> fails in s2io_add_isr.
> - Added two utility functions remove_msix_isr and remove_inta_isr to eliminate
> code duplication.
> - Implemented following review comments from Jeff
> 	- Removed redundant stats->mem_freed and synchronize_irq call
> 	- do_rem_msix_isr is renamed as remove_msix_isr
> 	- do_rem_inta_isr is renamed as remove_inta_isr
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

this patch should go into 2.6.24-rc, but it doesn't apply to upstream.

This may be because it requires "S2io: Support for 
add/delete/store/restore ethernet addresses", I am guessing?

We want to reverse the order of those two patches, because "S2io: 
Support for add/delete/store/restore ethernet addresses" is more 
appropriate for non-bug-fix 2.6.24 rather than current bugfix-only 
2.6.24-rc.

	Jeff


