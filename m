From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/1] forcedeth: replace pci_alloc_consistent
 with dma_alloc_coherent
Date: Mon, 30 Oct 2017 11:27:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00A8ABC@AcuExch.aculab.com>
References: <1509193530-25321-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Zhu Yanjun' <yanjun.zhu@oracle.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:52211 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752878AbdJ3L0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 07:26:50 -0400
In-Reply-To: <1509193530-25321-1-git-send-email-yanjun.zhu@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun
> Sent: 28 October 2017 13:26
> The functions pci_alloc_consistent is obsolete. So it is replaced
> with dma_alloc_coherent
...
> +			dma_free_coherent(&np->pci_dev->dev,
> +					  sizeof(struct ring_desc) *
> +					  (np->rx_ring_size +
> +					  np->tx_ring_size),
> +					  np->rx_ring.orig, np->ring_addr);
...

That can't possibly be the best way to split those long lines.

	David
