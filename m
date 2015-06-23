From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: switchdev: ignore unsupported bridge flags
Date: Tue, 23 Jun 2015 17:09:20 +0200
Message-ID: <20150623150920.GA2043@nanopsycho>
References: <1435069564-10241-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1435069564-10241-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Jun 23, 2015 at 04:26:04PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>switchdev_port_bridge_getlink() queries SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS
>attributes, but a driver doesn't need to implement this in order to get
>bridge link information.
>
>So error out only on errors different than -EOPNOTSUPP.
>
>(This is a follow-up patch for 7d4f8d8.)
>
>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Fixes: 8793d0a664a8 ("switchdev: add new switchdev_port_bridge_getlink")
Acked-by: Jiri Pirko <jiri@resnulli.us>
