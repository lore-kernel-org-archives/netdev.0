From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: store CPU port pointer in the tree
Date: Wed, 17 May 2017 14:19:31 -0400 (EDT)
Message-ID: <20170517.141931.1568766298440220602.davem@davemloft.net>
References: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753230AbdEQSTd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:19:33 -0400
In-Reply-To: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 16 May 2017 14:10:33 -0400

> A dsa_switch_tree instance holds a dsa_switch pointer and a port index
> to identify the switch port to which the CPU is attached.
> 
> Now that the DSA layer has a dsa_port structure to hold this data, use
> it to point the switch CPU port.
> 
> This patch simply substitutes s/dst->cpu_switch/dst->cpu_dp->ds/ and
> s/dst->cpu_port/dst->cpu_dp->index/.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
