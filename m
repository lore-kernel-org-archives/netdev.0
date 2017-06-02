From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: VF interrupt initialization cleanup
Date: Fri, 02 Jun 2017 14:14:41 -0400 (EDT)
Message-ID: <20170602.141441.82489466525012853.davem@davemloft.net>
References: <20170531164809.GA1497@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdFBSOx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:14:53 -0400
In-Reply-To: <20170531164809.GA1497@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 31 May 2017 09:48:09 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Set initialization state variable to (reflect interrupt initialization) at
> correct time (immediately after having configured interrupts).  This fixes
> problem of inconsistent IRQ allocation in case of [obscure] failure when
> negotiating with PF driver during init.
> 
> Clean-up of interrupt enablement during initialization & avoid potential
> race condition with chip-specific code (i.e. perform interrupt control in
> main driver module).  Added explanatory comments regarding interrupt
> enablement.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thank you.
