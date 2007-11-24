From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Fixed memory leak by freeing MSI-X local
 entry memories when vector allocation fails
Date: Fri, 23 Nov 2007 22:03:27 -0500
Message-ID: <4747947F.80506@garzik.org>
References: <Pine.GSO.4.10.10711140423410.18735-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39629 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803AbXKXDD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:03:29 -0500
In-Reply-To: <Pine.GSO.4.10.10711140423410.18735-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sreenivasa Honnur wrote:
> - Fixed memory leak by freeing MSI-X local entry memories when vector allocation
> fails in s2io_add_isr.
> - Added two utility functions remove_msix_isr and remove_inta_isr to eliminate
> code duplication.
> - Incorporated following review comments from Jeff
>         - Removed redundant stats->mem_freed and synchronize_irq call
>         - do_rem_msix_isr is renamed as remove_msix_isr
>         - do_rem_inta_isr is renamed as remove_inta_isr
> 
> - (Resubmit third time)

ditto, does not apply


