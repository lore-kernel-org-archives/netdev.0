From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: fix EDSA frame from hwaccel frame
Date: Mon, 03 Aug 2015 22:21:59 -0700 (PDT)
Message-ID: <20150803.222159.1711458384701896079.davem@davemloft.net>
References: <1438566362-28786-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438566362-28786-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun,  2 Aug 2015 21:46:02 -0400

> If the underlying network device features NETIF_F_HW_VLAN_CTAG_TX,
> an EDSA frame is prepended with a 802.1q header once queued.
> 
> To fix this, push the VLAN tag to the payload if present, before
> checking the frame protocol.
> 
> [note: we may prefer to access directly VLAN TCI from hwaccel frames,
> but this approach is simpler.]
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

This is a bug fix so should target 'net', but you generated the patch
against 'net-next'.

In any event, you should be explicit about the tree you are targetting
in order to not waste my time like this, by simply specifying the
tree in your "[PATCH xxx]" text in your subject line.   Either
"[PATCH net]" or "[PATCH net-next]".

Thanks.
