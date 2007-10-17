From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/4] WOL bugfix for 3c59x.c
Date: Tue, 16 Oct 2007 21:16:31 -0400
Message-ID: <4715626F.6060705@garzik.org>
References: <200710162124.l9GLO9t6017971@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	hcoin@n4comm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47562 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932576AbXJQBQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 21:16:33 -0400
In-Reply-To: <200710162124.l9GLO9t6017971@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> 
> Some NICs (3c905B) can not generate PME in power state PCI_D0, while others
> like 3c905C can.  Call pci_enable_wake() with PCI_D3hot should give proper
> WOL for 3c905B.
> 
> Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> Tested-by: Harry Coin <hcoin@n4comm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c59x.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)

applied


