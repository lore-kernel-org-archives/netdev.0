From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v5] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 25 Jan 2011 10:46:18 +0800
Message-ID: <AANLkTinedmQKBn0rEwE=tYfj37f6uXt3rFNp+xVPcwZm@mail.gmail.com>
References: <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
 <1295872799-1637-1-git-send-email-ratbert.chuang@gmail.com> <1295881662.2755.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46585 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab1AYCqk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 21:46:40 -0500
In-Reply-To: <1295881662.2755.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

On Mon, Jan 24, 2011 at 11:07 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 24 janvier 2011 =C3=A0 20:39 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>> +
>> + =C2=A0 =C2=A0 priv->tx_pending++;
>> + =C2=A0 =C2=A0 if (priv->tx_pending =3D=3D TX_QUEUE_ENTRIES) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev_info(netdev, "tx queue full\n");
>
> Hmm, I guess you didnt tested your driver with a pktgen flood ;)
>
> This 'netdev_info(netdev, "tx queue full\n");' is not necessary, sinc=
e
> its a pretty normal condition for a driver (to fill its TX ring buffe=
r)

Errr... No, I didn't test it with pktgen. I tested it with normal NFS u=
sages.
I'll try it.

best regards,
Po-Yu Chuang
