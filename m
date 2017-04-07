From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/4] net: dsa: add new DSA switch driver for the
 SMSC-LAN9303
Date: Fri, 07 Apr 2017 06:35:53 -0700 (PDT)
Message-ID: <20170407.063553.580195979968658177.davem@davemloft.net>
References: <20170407081502.30172-1-jbe@pengutronix.de>
        <20170407081502.30172-3-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: jbe@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170407081502.30172-3-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Juergen Borleis <jbe@pengutronix.de>
Date: Fri,  7 Apr 2017 10:15:00 +0200

> +static inline struct lan9303 *ds_to_lan9303(struct dsa_switch *ds)
> +{
> +	return (struct lan9303 *)ds->priv;
> +}

You never need an explicit cast from a void pointer to another kind of
pointer.  Please remove this.

In fact, this therefore makes the helper kind of useless and you can
just simply go:

	struct lan9303_priv *priv = ds->priv;

everywhere.
