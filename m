From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Fri, 29 Apr 2011 15:51:09 +0200
Message-ID: <20110429135108.GB2697@psychotron>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
 <BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
 <BANLkTikUAGWhNnCrebQpVttorqVxfD6KWw@mail.gmail.com>
 <20110428.132724.48500963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, netdev@vger.kernel.org, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133Ab1D2NvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 09:51:16 -0400
Content-Disposition: inline
In-Reply-To: <20110428.132724.48500963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 28, 2011 at 10:27:24PM CEST, davem@davemloft.net wrote:
>From: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
>Date: Fri, 22 Apr 2011 11:49:40 +0200
>
>> W dniu 22 kwietnia 2011 11:43 u=C5=BCytkownik Micha=C5=82 Miros=C5=82=
aw
>> <mirqus@gmail.com> napisa=C5=82:
>>> 2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>>>> The code is not needed because tb[IFLA_IFNAME] is already
>>>> processed in rtnl_newlink(). Remove this redundancy.
>>> Hi. This patch broke creation of veth devices. Reverting it fixes t=
he issue.
>>>
>>> Symptoms:
>>>
>>> icybox:~# ip link add type veth
>>> RTNETLINK answers: File exists
>>> icybox:~# ip link add type veth peer veth1
>>> icybox:~# ip addr
>>> [...]
>>> 56: D: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 10=
00
>>> =C2=A0 =C2=A0link/ether e6:57:58:52:03:50 brd ff:ff:ff:ff:ff:ff
>>> 57: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qle=
n 1000
>>> =C2=A0 =C2=A0link/ether c2:c2:a2:d5:d5:3a brd ff:ff:ff:ff:ff:ff
>>=20
>> Hmm. I was too quick. Reverting it fixes only first problem - "ip li=
nk
>> add type veth" adds new veth pair now, but "ip link add type veth pe=
er
>> veth1" gives the same result as above.
>
>Jiri please look into this regression.

Working on this. Will post patch soon.

Jirka
