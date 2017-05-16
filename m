From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: store CPU port pointer in the tree
Date: Tue, 16 May 2017 14:16:09 -0700
Message-ID: <4d3bf613-1eca-c857-cc78-0e1e6afa7774@gmail.com>
References: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34927 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750759AbdEPVQQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:16:16 -0400
In-Reply-To: <20170516181033.19980-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2017 11:10 AM, Vivien Didelot wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
