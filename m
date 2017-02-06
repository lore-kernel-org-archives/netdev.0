From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: dsa: add fabric notifier
Date: Mon, 06 Feb 2017 16:56:08 -0500 (EST)
Message-ID: <20170206.165608.1431079109938205254.davem@davemloft.net>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        cphealy@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  3 Feb 2017 13:20:15 -0500

> When a switch fabric is composed of multiple switch chips, these chips
> must be programmed accordingly when an event occurred on one of them.
> 
> Examples of such event include hardware bridging: when a Linux bridge
> spans interconnected chips, they must be programmed to allow external
> ports to ingress frames on their internal ports.
> 
> Another example is cross-chip hardware VLANs. Switch chips in-between
> interconnected bridge ports must also configure a given VLAN to allow
> packets to pass through them.
> 
> In order to support that, this patchset introduces a non-intrusive
> notifier mechanism. It adds a notifier head in every DSA switch tree
> (the said fabric), and a notifier block in every DSA switch chip.
 ...

Series applied, thanks Vivien.
