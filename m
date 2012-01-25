From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v3, kernel version 3.2.1] Source mode for macvlan interface
Date: Wed, 25 Jan 2012 07:56:04 +0100
Message-ID: <CAGsizzJc0EWuCf+zLBGJbfuMcKKcnnswCvid1pOVpUgJqTY43w@mail.gmail.com>
References: <12446987.2261327416407141.JavaMail.root@5-MeO-DMT.ynet.sk>
 <25119746.2341327416953583.JavaMail.root@5-MeO-DMT.ynet.sk>
 <20120124.230354.1696063062900108959.davem@davemloft.net> <CAGsizzLHT6jK8zJn+5eJkTUt5NBdpK9uNHJTzDCPrbCcPBvBNA@mail.gmail.com>
 <1327472968.14373.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327472968.14373.41.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=C5=88a 25. janu=C3=A1ra 2012 7:29, Eric Dumazet <eric.dumazet@gmail.c=
om> nap=C3=ADsal/a:
> Le mercredi 25 janvier 2012 =C3=A0 07:22 +0100, =C5=A0tefan Gula a =C3=
=A9crit :
>
>> It's a result of need to have enough space allocated for sk_buff
>> struct before called macvlan_fill_info. I know that it looks somehow
>> messy. BUt before the macvlan_fill_info is called there is only one
>> procedure calcit. The problem of calcit is that it doesn't have acce=
ss
>> to struct net_device *dev int it. It has only access to struct sk_bu=
ff
>> *skb, so from that point it cannot be called directly (whole parsing
>> code had to be copied there to get the *dev a calling
>> if_nlmsg_size(dev) from it. On the other hand calcit returns global
>> static value of min_ifinfo_dump_size and that is shared among all
>> interfaces and modifying like this do the job properly. There was
>> another different way and that was creating and registering a whole
>> new PF_MACLVAN netlink group resulting in copying almost 95% percent
>> of given code and modified it somehow to do the same.
>>
>> If it should be result of separate commitment than ok, but it was
>> result apparently of need only for use of macvlan that's why it was
>> included in my patch.
>>
>> So how should I proceed with it?
>
> A separate patch for this part, as David said ?
>
> The intent is to catch people attention on a particular point, instea=
d
> of unnoticed code in some huge unrelated patch.
>
>
>
Ok
