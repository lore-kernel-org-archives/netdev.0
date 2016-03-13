From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/3] net: dsa: finer bridging control
Date: Sun, 13 Mar 2016 18:47:13 +0100
Message-ID: <20160313174713.GC10666@lunn.ch>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 13, 2016 at 01:42:23AM -0500, Vivien Didelot wrote:
> This patchset renames the bridging routines of the DSA layer, make the
> unbridging routine return void, and rework the DSA netdev notifier handler,
> similar to what the Mellanox Spectrum driver does.

Tested-by: Andrew Lunn <andrew@lunn.ch>

Do you think there could be some consolidation of code with Mellanox,
and other switchdev devices? Moving it into the switchdev core?

    Andrew
