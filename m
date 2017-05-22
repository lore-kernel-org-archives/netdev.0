From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/20] net: dsa: distribute switch events
Date: Mon, 22 May 2017 10:45:57 -0400 (EDT)
Message-ID: <20170522.104557.1244582147577060590.davem@davemloft.net>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 19 May 2017 17:00:35 -0400

> DSA is by nature the support for a switch fabric, which can be composed
> of a single, or multiple interconnected Ethernet switch chips.
> 
> The current DSA core behavior is to identify the slave port targeted by
> a request (e.g. adding a VLAN entry), and program the switch chip to
> which it belongs accordingly.
> 
> This is problematic in a multi-chip environment, since all chips of a
> fabric must be aware of most configuration changes. Here are some
> concrete examples in a 3-chip environment:
 ...
> This patch series uses the notification chain introduced for bridging,
> to notify not only bridge, but switchdev attributes and objects events
> to all switch chips of the fabric.

Andrew or Florian, can I get a review?

I audited the slave-->port transformations and they all look
good.
