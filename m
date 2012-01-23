From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] Source mode for macvlan
 interaface
Date: Mon, 23 Jan 2012 15:11:19 +0100
Message-ID: <1327327879.2525.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22013455.801327321838477.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 23 janvier 2012 =C3=A0 13:30 +0100, Stefan Gula a =C3=A9crit :
> From: Stefan Gula <steweg@gmail.com>
>=20
> New mode of macvlan interface called "source" allows one to specify,
> which  frames are allowed to be received by given macvlan interface.
> This logic is used only on received frames on underlaying interface.
> The ability to send frames from macvlan interface through underlaying
> interface is not modified. This feature allows one to simulate 802.1x
> mac based VLAN bahaviour by using proper netlink message to configure
> this behavior with utililty such as "ip link" from iproute2 suite.
>=20
> Signed-off-by: Stefan Gula <steweg@gmail.com>

Please limit line lengths to 70 chars.

I dont understand your patch description at all, and reading its body I
still dont understand its purpose.

Is it sort of firewall rules (ebtable) or bridging code ?

> +static void macvlan_hash_del_sources(struct macvlan_source_list *lis=
t,
> +					bool sync)
> +{
> +	hlist_del_rcu(&list->hlist);
> +	kfree_rcu(list, rcu);
> +	if (sync)
> +		synchronize_rcu();
> +}
> +

Please explain why are you using synchronize_rcu() here, as there must
be a good reason, but I missed it.
