From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 16:57:01 +0200
Message-ID: <1271775421.7895.19.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
	 <1271750198.3845.216.camel@edumazet-laptop>
	 <4BCDA2B5.4060609@lastsummer.de> <1271769404.7895.10.camel@edumazet-laptop>
	 <4BCDB425.9050007@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:49145 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718Ab0DTO5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 10:57:08 -0400
Received: by bwz19 with SMTP id 19so51715bwz.21
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 07:57:07 -0700 (PDT)
In-Reply-To: <4BCDB425.9050007@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 16:03 +0200, Franco Fichtner a =C3=A9crit=
 :

>=20
> It is funny, but I fail to see the big picture of the
> firewall / conntrack application here. It looks like
> this is needed for local netperf tests to impress, but
> it's a quite special use case, isn't it?

I know many applications using TCP on loopback, they are real :)

What I find 'funny' are not the tbench results, but the fact that RFS
can give pretty good hints to process scheduler, something that might b=
e
good to investigate by scheduler specialists.

In the meantime, if some admin finds that setting RFS on loopback can
boost by 10% its application, why not ?



