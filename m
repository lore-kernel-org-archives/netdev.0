From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Tue, 28 Oct 2014 06:31:40 -0700
Message-ID: <544F9ABC.4010306@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net> <1414342365-27191-10-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-10-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2014 09:52 AM, Guenter Roeck wrote:
> On some chips it is possible to access the switch eeprom.
> Add infrastructure support for it.
>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---

[ ... ]

> @@ -603,6 +604,9 @@ static int dsa_of_probe(struct platform_device *pdev)
>   	if (pd->nr_chips > DSA_MAX_SWITCHES)
>   		pd->nr_chips = DSA_MAX_SWITCHES;
>
> +	if (!of_property_read_u32(np, "eeprom-length", &eeprom_length))
> +		pd->eeprom_length = eeprom_length;

This is buggy; please don't apply. Variable is named eeprom_len, and it is
per switch.

Lesson to self: When writing devicetree code, compile it with devicetree enabled.

Guenter
