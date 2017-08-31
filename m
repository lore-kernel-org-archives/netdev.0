From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix crash in presence of zeroed-out
 base address regs
Date: Wed, 30 Aug 2017 22:07:49 -0700 (PDT)
Message-ID: <20170830.220749.1080721940498362679.davem@davemloft.net>
References: <20170830231953.GA14744@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdHaFHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 01:07:50 -0400
In-Reply-To: <20170830231953.GA14744@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 30 Aug 2017 16:19:53 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Fix crash in linux PF driver when BARs have been cleared/de-programmed;
> fail early init (prior to mapping BARs) if the BAR0 or
> BAR1 registers are zero.
> 
> This situation can arise when the PF is added to a VM (PCI pass-through),
> then a PF FLR is issued (in the VM).  After this occurs, the BAR registers
> will be zero. If we attempt to load the PF driver in the host
> (after VM has been shutdown), the host can reset.
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
