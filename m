From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] net: dsa: define port types
Date: Sat, 28 Oct 2017 00:00:27 +0900 (KST)
Message-ID: <20171028.000027.15576492722845843.davem@davemloft.net>
References: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026152259.3123-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 26 Oct 2017 11:22:50 -0400

> The DSA code currently has 3 bitmaps in the dsa_switch structure:
> cpu_port_mask, dsa_port_mask and enabled_port_mask.
> 
> They are used to store the type of each switch port. This dates back
> from when DSA didn't have a dsa_port structure to hold port-specific
> data.
> 
> The dsa_switch structure is mainly used to communicate with DSA drivers
> and must not contain such static data parsed from DTS or pdata, which
> belongs the DSA core structures, such as dsa_switch_tree and dsa_port.
> 
> Also the enabled_port_mask is misleading, often misinterpreted as the
> complement of disabled ports (thus including DSA and CPU ports), while
> in fact it only masks the user ports.
> 
> A port can be of 3 types when it is not unused: "cpu" (interfacing with
> a master device), "dsa" (interconnecting with another "dsa" port from
> another switch chip), or "user" (user-facing port.)
> 
> This patchset first fixes the usage of DSA port type helpers, then
> defines the DSA_PORT_TYPE_UNUSED, DSA_PORT_TYPE_CPU, DSA_PORT_TYPE_DSA,
> and DSA_PORT_TYPE_USER port types, and finally removes the misleading
> port bitmaps.

Series applied, thanks Vivien.
