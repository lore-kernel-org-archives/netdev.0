From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: fullly using NETIF_F_GSO_SOFTWARE
 macros and NETIF_F_SOFT_FEATURES
Date: Fri, 22 Apr 2011 13:39:28 +0200
Message-ID: <BANLkTi=X_LvQ1-SA5-P6rs3akY2tGbHryQ@mail.gmail.com>
References: <4DB16181.9010306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, rusty@rustcorp.com.au,
	mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	krkumar2@in.ibm.com, mirq-linux@rere.qmqm.pl, joe@perches.com
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:37292 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab1DVLjt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 07:39:49 -0400
Received: by qyg14 with SMTP id 14so274407qyg.19
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2011 04:39:48 -0700 (PDT)
In-Reply-To: <4DB16181.9010306@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/22 Shan Wei <shanwei@cn.fujitsu.com>:
> Fullly using NETIF_F_GSO_SOFTWARE and NETIF_F_SOFT_FEATURES.
> And some code style tuning. Just compile test.
[...]

Plese don't replace feature sets with masks of them like that. The
values are the same, but it will confuse readers as to the meaning of
the code.

Best Regards,
Micha=C5=82 Miros=C5=82aw
