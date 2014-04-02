From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] netconsole: Add tty driver
Date: Thu, 3 Apr 2014 01:12:35 +0200
Message-ID: <20140402231235.GA5013@electric-eye.fr.zoreil.com>
References: <20140402185904.GD11734@NewsNow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	Andreas Schwab <schwab@linux-m68k.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Pirko <jiri@resnulli.us>, Joe Perches <joe@perches.com>,
	Dan Aloni <alonid@postram.com>
To: Struan Bartlett <struan.bartlett@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140402185904.GD11734@NewsNow.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Struan Bartlett <struan.bartlett@gmail.com> :
[...]
> --- a/drivers/net/netconsole.c	2014-03-31 04:40:15.000000000 +0100
> +++ b/drivers/net/netconsole.c	2014-04-01 11:58:50.000000000 +0100
> @@ -15,6 +15,7 @@
>   *               generic card hooks
>   *               works non-modular
>   * 2003-09-07    rewritten with netpoll api
> + * 2014-03-31    tty driver by Struan Bartlett

Useless.

[...]
> +static int netconsole_tty_put_char(struct tty_struct *tty, unsigned char ch)
> +{
> +	char temp[2] = { ch, 0 };
> +	_write_msg(temp, 1);

Please add an empty line after declaration.

[...]
> @@ -802,11 +857,39 @@ static int __init init_netconsole(void)
>  	if (err)
>  		goto undonotifier;
>  
> +	netconsole_tty_driver = alloc_tty_driver(1);

alloc_tty_driver is said deprecated in include/linux/tty_driver.h

http://marc.info/?l=linux-netdev&m=139629339513575 may delay things a bit.
If so please be patient.

-- 
Ueimor
