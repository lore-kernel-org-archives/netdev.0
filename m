From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: change dsa_ptr for a dsa_port
Date: Sun, 01 Oct 2017 04:15:25 +0100 (WEST)
Message-ID: <20171001.041525.1993590077484803835.davem@davemloft.net>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 29 Sep 2017 17:19:14 -0400

> With DSA, a master net_device is physically wired to a dedicated CPU
> switch port. For interaction with the DSA layer, the struct net_device
> contains a dsa_ptr, which currently points to a dsa_switch_tree object.
> 
> This is only valid for a switch fabric with a single CPU port. In order
> to support switch fabrics with multiple CPU ports, we first need to
> change the type of dsa_ptr to what it really is: a dsa_port object.
> 
> This is what this patchset does. The first patches adds a
> dsa_master_get_slave helper and cleans up portions of DSA core to make
> the next patches more readable. These next patches prepare the xmit and
> receive hot paths and finally change dsa_ptr.
> 
> Changes in v2:
>   - introduce dsa_master_get_slave helper to simplify patch 6
>   - keep hot path data at beginning of dsa_port for cacheline 1

Series applied, thank you.
