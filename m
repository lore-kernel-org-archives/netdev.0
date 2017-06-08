From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] net: dsa: add cross-chip VLAN support
Date: Thu, 08 Jun 2017 11:44:07 -0400 (EDT)
Message-ID: <20170608.114407.1854285894299317374.davem@davemloft.net>
References: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607221217.2323-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  7 Jun 2017 18:12:12 -0400

> The current code in DSA does not support cross-chip VLAN. This means
> that in a multi-chip environment such as this one (similar to ZII Rev B)
 ...
> adding a VLAN to p9 won't be enough to reach the CPU, until at least one
> port of sw0 and sw1 join the VLAN as well and become aware of the VID.
> 
> This patchset makes the DSA core program the VLAN on the CPU and DSA
> links itself, which brings seamlessly cross-chip VLAN support to DSA.
> 
> With this series applied*, the hardware VLAN tables of a 3-switch setup
> look like this after adding a VLAN to only one port of the end switch:
  ...
> Completely removing a VLAN entry (which is currently the responsibility
> of drivers anyway) is not supported yet since it requires some caching.
> 
> (*) the output is shown from this out-of-tree debugfs patch:
> https://github.com/vivien/linux/commit/7b61a684b9d6b6a499135a587c7f62a1fddceb8b.patch
> 
> Changes in v2:
>   - canonical incrementation (port++ instead of ++port)
>   - check CPU and DSA ports before purging a VLAN
>   - add Reviewed-by tags

Series applied, thanks Vivien.
