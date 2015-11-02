From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net: dsa: mv88e6xxx: lookup switch name
Date: Mon, 2 Nov 2015 16:05:08 +0100
Message-ID: <20151102150508.GD7963@lunn.ch>
References: <1446248388-21060-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446248388-21060-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 07:39:48PM -0400, Vivien Didelot wrote:
> All the mv88e6xxx drivers use the exact same code in their probe
> function to lookup the switch name given its ID. Thus introduce a
> mv88e6xxx_switch_id structure and a mv88e6xxx_lookup_name function in
> the common mv88e6xxx code.
> 
> In the meantime make __mv88e6xxx_reg_{read,write} static since we do not
> need to expose these low-level r/w routines anymore.

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
