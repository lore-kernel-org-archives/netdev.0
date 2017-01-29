From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] net: dsa: preparatory patches for
 multi-chip
Date: Sun, 29 Jan 2017 18:43:18 -0500 (EST)
Message-ID: <20170129.184318.570328601635131826.davem@davemloft.net>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        john@phrozen.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 27 Jan 2017 15:29:35 -0500

> In order to introduce support for multi-chip configuration, we need to
> do a few enhancements. This patchset makes the number of ports in a
> switch dynamic (instead of capping to DSA_MAX_PORTS), stores the switch
> and index of a port in the dsa_port structure, uses it in the slave
> private structure, and exposes the bridge device a port belongs to.

I never liked the fixed sized port array and am happy to see it made
dynamic.

Series applied, thanks.
