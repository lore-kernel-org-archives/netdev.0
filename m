From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 10/14] net: dsa/mv88e6352: Implement EEPROM access
 functions
Date: Thu, 23 Oct 2014 15:54:12 +0200
Message-ID: <20141023135412.GC25190@lunn.ch>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-11-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414037002-25528-11-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 22, 2014 at 09:03:18PM -0700, Guenter Roeck wrote:
> MV88E6352 supports read and write access to its configuration eeprom.

Hi Guenter

I don't have the datasheet for the MV88E6352. Is the EEPROM built in,
or external on an i2c bus?

> +static int mv88e6352_get_eeprom_len(struct dsa_switch *ds)
> +{
> +	return 0x200;
> +}

How do you handle the case of it being external and not populated.
Would it not be better to try to detect it here, and return 0 if it
does not exist?

      Andrew
