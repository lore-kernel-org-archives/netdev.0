From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] net: dsa: make port_bridge_leave return void
Date: Sun, 13 Mar 2016 21:56:54 +0100
Message-ID: <20160313205653.GC2274@nanopsycho.orion>
References: <1457900494-10266-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1457900494-10266-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457900494-10266-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Mar 13, 2016 at 09:21:33PM CET, vivien.didelot@savoirfairelinux.com wrote:
>netdev_upper_dev_unlink() which notifies NETDEV_CHANGEUPPER, returns
>void, as well as del_nbp(). So there's no advantage to catch an eventual
>error from the port_bridge_leave routine at the DSA level.
>
>Make this routine void for the DSA layer and its existing drivers.
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
