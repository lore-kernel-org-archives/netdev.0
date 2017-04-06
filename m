From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Thu, 6 Apr 2017 06:53:10 -0700
Message-ID: <33d61a69-462f-dfb4-98f1-911882b0d466@gmail.com>
References: <20170405092024.16048-1-jbe@pengutronix.de>
 <20170405092024.16048-5-jbe@pengutronix.de> <20170405193219.GC25803@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>, Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405193219.GC25803@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/05/2017 12:32 PM, Andrew Lunn wrote:
>> +static const struct of_device_id lan9303_mdio_of_match[] = {
>> +	{ .compatible = "smsc,lan9303" },
>> +	{ /* sentinel */ },
>> +};
>> +MODULE_DEVICE_TABLE(of, lan9303_mdio_of_match);
> 
> If i'm reading this right, i think you have the same compatible string
> for both the i2c and the mdio driver. Does that work? I've no idea.

This should not be a problem, actually, this does seem like the right
thing to do. The bus topology would solve the Linux device creation such
that you would probe either via mdio or i2c (or both) but through the
appropriate drivers' probe functions.
-- 
Florian
