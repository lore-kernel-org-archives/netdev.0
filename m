From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix use of pf in pass-through mode
 in a virtual machine
Date: Sun, 20 Aug 2017 20:21:45 -0700 (PDT)
Message-ID: <20170820.202145.1702048414230943774.davem@davemloft.net>
References: <20170819012149.GA4838@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750985AbdHUDVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 23:21:46 -0400
In-Reply-To: <20170819012149.GA4838@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 18 Aug 2017 18:21:49 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Fix problem when PF is used in pass-through mode in a VM (w/embedded f/w).
> 
> If host error reading PF num from CN23XX_PCIE_SRIOV_FDL reg,
> try to retrieve PF num from SLI_PKT(0)_INPUT_CONTROL (initialized by f/w).
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
