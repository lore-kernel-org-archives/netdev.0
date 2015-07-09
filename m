From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Add support for Marvell
 88E6320 and 88E6321
Date: Thu, 09 Jul 2015 10:53:23 +0200
Message-ID: <1436432003.20619.102.camel@tiscali.nl>
References: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"Aleksey S. Kazantsev" <ioctl@yandex.ru>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On di, 2015-07-07 at 20:38 -0700, Guenter Roeck wrote:
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
 
> -MODULE_ALIAS("platform:mv88e6352");
>  MODULE_ALIAS("platform:mv88e6172");
> +MODULE_ALIAS("platform:mv88e6176");
> +MODULE_ALIAS("platform:mv88e6320");
> +MODULE_ALIAS("platform:mv88e6321");
> +MODULE_ALIAS("platform:mv88e6352");

Naive question: there are quite a few similar MODULE_ALIAS() macros in
drivers/net/dsa. That is, macros using "platform:mv88e6[...]". But I
couldn't find the struct platform_device's that would, in short, fire
off the corresponding "MODALIAS=platform:mv88e6[...]" uevent when
they're created. Where should I look for those struct platform_device's?

Thanks,


Paul Bolle
