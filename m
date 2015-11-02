From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: dsa: mv88e6xxx: lookup switch name
Date: Mon, 02 Nov 2015 15:54:52 -0500 (EST)
Message-ID: <20151102.155452.2035474549929551377.davem@davemloft.net>
References: <1446248388-21060-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
	linux@roeck-us.net, narmstrong@baylibre.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446248388-21060-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 30 Oct 2015 19:39:48 -0400

> All the mv88e6xxx drivers use the exact same code in their probe
> function to lookup the switch name given its ID. Thus introduce a
> mv88e6xxx_switch_id structure and a mv88e6xxx_lookup_name function in
> the common mv88e6xxx code.
> 
> In the meantime make __mv88e6xxx_reg_{read,write} static since we do not
> need to expose these low-level r/w routines anymore.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
