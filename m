From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Fix multicast list setup in fec_restart().
Date: Fri, 21 Jun 2013 14:15:40 -0300
Message-ID: <CAOMZO5CyK9S-Wmm+ihBeMCaDBJyxBb-vSQjzZiKrmz74mb=vDw@mail.gmail.com>
References: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Christoph_M=C3=BCllner?=
	<christoph.muellner@theobroma-systems.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <61455.62.178.124.14.1371832855.squirrel@mail.theobroma-systems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 21, 2013 at 1:40 PM, Christoph M=C3=BCllner
<christoph.muellner@theobroma-systems.com> wrote:

> @@ -472,8 +474,7 @@ fec_restart(struct net_device *ndev, int duplex)
>         writel(0xffc00000, fep->hwp + FEC_IEVENT);
>
>         /* Reset all multicast. */

Should this comment be removed/updated now?

> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
> -       writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
> +       set_multicast_list(ndev);
