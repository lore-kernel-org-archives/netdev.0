From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH next 5/6] bonding: Allow userspace to set macaddr on
 bonding-dev
Date: Sat, 7 Feb 2015 14:26:52 -0800
Message-ID: <20150207142652.708bd66e@urahara>
References: <1423270316-9311-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43187 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069AbbBGW0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 17:26:54 -0500
Received: by pdbfl12 with SMTP id fl12so12387760pdb.10
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 14:26:53 -0800 (PST)
In-Reply-To: <1423270316-9311-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  6 Feb 2015 16:51:56 -0800
Mahesh Bandewar <maheshb@google.com> wrote:

> @@ -396,6 +398,13 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>  		.values = bond_ad_actor_sysprio_tbl,
>  		.set = bond_option_ad_actor_sysprio_set,
>  	},
> +	[BOND_OPT_AD_ACTOR_SYS_MACADDR] = {
> +		.id = BOND_OPT_AD_ACTOR_SYS_MACADDR,
> +		.name = "ad_actor_system_mac_address",
> +		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
> +		.flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
> +		.set = bond_option_ad_actor_sys_macaddr_set,
> +	},
>  };

I would consider the module command line options deprecated
at this point. Why add more?
