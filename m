From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 20 Apr 2010 07:59:24 +0200
Message-ID: <1271743164.3845.128.camel@edumazet-laptop>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:43662 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0DTF7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 01:59:31 -0400
Received: by bwz19 with SMTP id 19so139527bwz.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 22:59:30 -0700 (PDT)
In-Reply-To: <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 07:38 +0800, Changli Gao a =C3=A9crit :

> Does this problem has relationship with your patch? No. If the rxhash
> isn't provided by hardware, we can get more throughput from you patch=
,
> and on the other side, we don't lose anything but potential more hash
> collision.
>=20

I am not sure what you call hash collision. There is no hash chain here=
=2E

This 32bit hash is a jhash one, and we only need 1 to 12 bits in it, I
am pretty sure its OK.



