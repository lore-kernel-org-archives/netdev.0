From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix for iq and droq cnts going
 negative
Date: Wed, 01 Feb 2017 12:25:57 -0500 (EST)
Message-ID: <20170201.122557.2156695603133130645.davem@davemloft.net>
References: <20170131210442.GA5435@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40424 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753447AbdBARZ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:25:59 -0500
In-Reply-To: <20170131210442.GA5435@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 31 Jan 2017 13:04:42 -0800

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Flush the mmio writes before releasing spin locks.
> if the maintained counts get too high > 2M force
> writeback of the counts to clear them
> 
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>

Applied, thanks.
