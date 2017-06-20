From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [PATCH v2 net-next] bonding: Convert multiple
 netdev_info messages to netdev_dbg
Date: Tue, 20 Jun 2017 16:28:02 -0700
Message-ID: <1498001282.12185.2.camel@perches.com>
References: <1497996331-24500-1-git-send-email-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michael J Dilmore <michael.j.dilmore@gmail.com>,
        j.vosburgh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497996331-24500-1-git-send-email-michael.j.dilmore@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-06-20 at 23:05 +0100, Michael J Dilmore wrote:
> The bond_options.c file contains several netdev_info messages that clutter kernel output. This patch changes all netdev_info messages
> to netdev_dbg and adds a netdev debug for the packets per slave parameter.

Hey Michael.

You should realign the multiple-line statements
to the open parentheses.

cheers, Joe

> diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
[]
> @@ -721,13 +721,13 @@ static int bond_option_mode_set(struct bonding *bond,
>  				const struct bond_opt_value *newval)
>  {
>  	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
> -		netdev_info(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
> +		netdev_dbg(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
>  			    newval->string);

Now all these are not aligned properly.

etc...
