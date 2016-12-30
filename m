From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: optimize reads from Octeon PCI
 console
Date: Thu, 29 Dec 2016 22:26:23 -0500 (EST)
Message-ID: <20161229.222623.1253518242752301173.davem@davemloft.net>
References: <20161230010447.GA6015@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752946AbcL3D0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 22:26:30 -0500
In-Reply-To: <20161230010447.GA6015@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 29 Dec 2016 17:04:47 -0800

> Reads from Octeon PCI console are inefficient because before each read
> operation, a dynamic mapping to Octeon DRAM is set up.  This patch replaces
> the repeated setup of a dynamic mapping with a one-time setup of a static
> mapping.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
