From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net v2] Altera TSE: Add missing include to silence sparse warnings
Date: Mon, 28 Apr 2014 17:27:56 -0500
Message-ID: <CAOwfj2PJLtDBv3TKZ9LkqFeDd2e346YLGyvCedQ+9h8zJqRrDg@mail.gmail.com>
References: <1398720193-19499-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nios2-dev@lists.rocketboards.org
To: Tobias Klauser <tobias.klauser@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:59026 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaD1W15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 18:27:57 -0400
Received: by mail-we0-f176.google.com with SMTP id x48so6855585wes.7
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 15:27:56 -0700 (PDT)
In-Reply-To: <1398720193-19499-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 4:23 PM, Tobias Klauser
<tobias.klauser@gmail.com> wrote:
> This fixes the following sparse warnings:
>
> drivers/net/ethernet/altera/altera_msgdma.c:23:5: warning: symbol 'msgdma_initialize' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:28:6: warning: symbol 'msgdma_uninitialize' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:32:6: warning: symbol 'msgdma_reset' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:77:6: warning: symbol 'msgdma_disable_rxirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:83:6: warning: symbol 'msgdma_enable_rxirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:89:6: warning: symbol 'msgdma_disable_txirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:95:6: warning: symbol 'msgdma_enable_txirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:101:6: warning: symbol 'msgdma_clear_rxirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:107:6: warning: symbol 'msgdma_clear_txirq' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:114:5: warning: symbol 'msgdma_tx_buffer' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:129:5: warning: symbol 'msgdma_tx_completions' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:154:5: warning: symbol 'msgdma_add_rx_desc' was not declared. Should it be static?
> drivers/net/ethernet/altera/altera_msgdma.c:181:5: warning: symbol 'msgdma_rx_status' was not declared. Should it be static?
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
> v2: patch rebased against current net tree
>

Acked-by: Vince Bridgers <vbridgers2013@gmail.com>

Thanks Tobias!

Vince
