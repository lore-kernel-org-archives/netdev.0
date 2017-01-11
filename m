From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: dsa: make "label" property optional
 for dsa2
Date: Wed, 11 Jan 2017 09:27:34 -0500 (EST)
Message-ID: <20170111.092734.1181805618953056278.davem@davemloft.net>
References: <20170109231351.5023-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jiri@resnulli.us, uwe@kleine-koenig.org, andrew.smirnov@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170109231351.5023-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  9 Jan 2017 18:13:51 -0500

> In the new DTS bindings for DSA (dsa2), the "ethernet" and "link"
> phandles are respectively mandatory and exclusive to CPU port and DSA
> link device tree nodes.
> 
> Simplify dsa2.c a bit by checking the presence of such phandle instead
> of checking the redundant "label" property.
> 
> Then the Linux philosophy for Ethernet switch ports is to expose them to
> userspace as standard NICs by default. Thus use the standard enumerated
> "eth%d" device name if no "label" property is provided for a user port.
> This allows to save DTS files from subjective net device names.
> 
> If one wants to rename an interface, udev rules can be used as usual.
> 
> Of course the current behavior is unchanged, and the optional "label"
> property for user ports has precedence over the enumerated name.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Acked-by: Uwe Kleine-König <uwe@kleine-koenig.org>

Applied, thanks.
