From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: set 802.1Q mode to
 Fallback
Date: Sun, 23 Aug 2015 15:54:52 -0700 (PDT)
Message-ID: <20150823.155452.256034175915598661.davem@davemloft.net>
References: <1440024895-22803-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440024895-22803-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 19 Aug 2015 18:54:55 -0400

> The current Secure port mode requires the port-based VLANs to also be
> valid in the 802.1Q VLAN Table Unit. The current hardware bridging
> support only configures the port-based VLANs, thus is broken.
> 
> A new patchset is required to adapt the hardware bridging code to fully
> support the Secure port mode.
> 
> In the meantime, change the 802.1Q mode of every ports to Fallback,
> which filtering is more permissive, and doesn't add this restriction to
> handle port-based and tagged-based VLANs.
> 
> Fixes: 8efdda4a1b60 ("net: dsa: mv88e6xxx: use port 802.1Q mode Secure")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
