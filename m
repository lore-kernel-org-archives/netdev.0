From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cxgb3: Remove incorrect __devinit annotations
Date: Wed, 30 Jan 2008 03:38:55 -0500
Message-ID: <47A0379F.5090804@garzik.org>
References: <adak5lsdzew.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47024 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754504AbYA3Ii6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:38:58 -0500
In-Reply-To: <adak5lsdzew.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> When PCI error recovery was added to cxgb3, a function t3_io_slot_reset()
> was added.  This function can call back into t3_prep_adapter() at any
> time, so t3_prep_adapter() can no longer be marked __devinit.
> This patch removes the __devinit annotation from t3_prep_adapter() and
> all the functions that it calls, which fixes
> 
>     WARNING: drivers/net/cxgb3/built-in.o(.text+0x2427): Section mismatch in reference from the function t3_io_slot_reset() to the function .devinit.text:t3_prep_adapter()
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> ---
>  drivers/net/cxgb3/mc5.c   |    2 +-
>  drivers/net/cxgb3/sge.c   |    2 +-
>  drivers/net/cxgb3/t3_hw.c |   22 ++++++++++------------
>  3 files changed, 12 insertions(+), 14 deletions(-)

applied


