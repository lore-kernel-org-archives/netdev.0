From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] Source mode for macvlan interface
Date: Thu, 26 Jan 2012 12:04:50 +0100
Message-ID: <CAGsizzLp11qzJGTYr+m49yi=2RyWTjkOzaT7d3ni0EfvPsKmHg@mail.gmail.com>
References: <25353423.731327481250682.JavaMail.root@5-MeO-DMT.ynet.sk>
 <32686570.751327481334943.JavaMail.root@5-MeO-DMT.ynet.sk> <20120125.213802.119259327303074622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120125.213802.119259327303074622.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/26 David Miller <davem@davemloft.net>:
> From: Stefan Gula <steweg@ynet.sk>
> Date: Wed, 25 Jan 2012 09:48:54 +0100 (CET)
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (vlan->mode =3D=3D MACVLAN_MODE_SOURCE =
&&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan->mode !=3D nla_get_u3=
2(data[IFLA_MACVLAN_MODE]))
> =A0...
>> + =A0 =A0 if (data && data[IFLA_MACVLAN_MACADDR_MODE] &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 data[IFLA_MACVLAN_MACADDR]) {
> =A0...
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mac=
vlan_hash_add_sources(vlan,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 nla_data(data[IFLA_MACVLAN_MACADDR]));
> =A0...
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_rcu(l=
ist, n,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &vlan->por=
t->vlan_source_hash[i], hlist) {
> =A0...
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_rcu(l=
ist, n,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &vlan->por=
t->vlan_source_hash[i], hlist) {
>
> Line things up on subsequent lines to the column right after the
> openning parenthesis on the previous line.
>
> If things are indented too deeply, you need to write helper functions=
=2E
Just to be sure, how many "\t" symbols are ok in patches? I want to
avoid similar thing in future.
