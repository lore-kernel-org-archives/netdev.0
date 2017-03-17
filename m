From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: remove/replace invalid code
Date: Thu, 16 Mar 2017 20:16:09 -0700 (PDT)
Message-ID: <20170316.201609.764940367660329908.davem@davemloft.net>
References: <20170313190731.GA1756@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdCQDQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:16:29 -0400
In-Reply-To: <20170313190731.GA1756@felix2.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 13 Mar 2017 12:07:32 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Remove invalid call to dma_sync_single_for_cpu() because previous DMA
> allocation was coherent--not streaming.  Remove code that references fields
> in struct list_head; replace it with calls to list_empty() and
> list_first_entry().  Also, add comment to clarify complicated if statement.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied.
