From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Fri, 07 Apr 2017 07:27:52 -0700 (PDT)
Message-ID: <20170407.072752.496227480340210620.davem@davemloft.net>
References: <20170407081502.30172-1-jbe@pengutronix.de>
        <20170407081502.30172-5-jbe@pengutronix.de>
        <20170407141925.GB23415@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbe@pengutronix.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170407141925.GB23415@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 7 Apr 2017 16:19:25 +0200

>> +static const struct of_device_id lan9303_mdio_of_match[] = {
>> +	{ .compatible = "smsc,lan9303" },
>> +	{ /* sentinel */ },
>> +};
> 
> We still have the open question of is it a problem to have two
> different drivers using the same compatible string. Changing these
> strings is hard, once they are in use, so i would prefer to get this
> answered before the code is accepted.

Agreed.
