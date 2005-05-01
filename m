From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 4/4] resource release cleanup in net/ (take 2)
Date: Sun, 01 May 2005 11:09:29 +0900 (JST)
Message-ID: <20050501.110929.34344394.yoshfuji@linux-ipv6.org>
References: <39e6f6c705043014264eb4c0c5@mail.gmail.com>
	<Pine.LNX.4.62.0505010341560.2094@dragon.hyggekrogen.localhost>
	<Pine.LNX.4.62.0505010352210.2094@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, arnaldo.melo@gmail.com,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jkmaline@cc.hut.fi, jmorris@intercode.com.au, roque@di.fc.ul.pt,
	kuznet@ms2.inr.ac.ru, kunihiro@ipinfusion.com, mk@linux-ipv6.org,
	lksctp-developers@lists.sourceforge.net, andros@umich.edu,
	bfields@umich.edu, netdev@oss.sgi.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: juhl-lkml@dif.dk
In-Reply-To: <Pine.LNX.4.62.0505010352210.2094@dragon.hyggekrogen.localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <Pine.LNX.4.62.0505010352210.2094@dragon.hyggekrogen.localhost> (at Sun, 1 May 2005 03:55:37 +0200 (CEST)), Jesper Juhl <juhl-lkml@dif.dk> says:

> > 	4) whitespace changes
:

Please add me cc: next time...

>--- linux-2.6.12-rc3-mm1/net/ipv6/ah6.c.old3	2005-05-01 03:24:09.000000000 +0200
>+++ linux-2.6.12-rc3-mm1/net/ipv6/ah6.c	2005-05-01 03:24:20.000000000 +0200
>@@ -305,6 +305,7 @@
> 	skb_pull(skb, hdr_len);
> 	skb->h.raw = skb->data;
> 
>+
> 	kfree(tmp_hdr);
> 
> 	return nexthdr;

Why?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
Homepage: http://www.yoshifuji.org/~hideaki/
GPG FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
