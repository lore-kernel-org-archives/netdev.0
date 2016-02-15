From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 18:54:29 -0200
Message-ID: <CAOMZO5AO4KY+PcQ7ka5Ot-TL222frLO50On+tFXFWGkKhQ25PA@mail.gmail.com>
References: <1455566460-31291-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Clemens Gruber <clemens.gruber@pqgruber.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455566460-31291-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2016 at 6:01 PM, Clemens Gruber
<clemens.gruber@pqgruber.com> wrote:

> +static int marvell_config_init(struct phy_device *phydev)
> +{
> +       int err;
> +
> +       /* Set registers from marvell,reg-init DT property */
> +       err = marvell_of_reg_init(phydev);
> +       if (err < 0)
> +               return err;
> +
> +       return 0;
>  }

Couldn't this be replaced by

return marvell_of_reg_init(phydev); ?
