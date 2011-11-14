From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: reduce skb truesize by 50%
Date: Mon, 14 Nov 2011 07:25:45 +0100
Message-ID: <1321251945.17837.55.camel@edumazet-laptop>
References: <1321213338.17837.38.camel@edumazet-laptop>
	 <1321214895.3101.3.camel@lb-tlvb-eilong.il.broadcom.com>
	 <1321221657.17837.51.camel@edumazet-laptop>
	 <20111114.000811.780218767629149648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:41075 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab1KNGZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 01:25:49 -0500
Received: by wwi18 with SMTP id 18so4365626wwi.1
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 22:25:48 -0800 (PST)
In-Reply-To: <20111114.000811.780218767629149648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 00:08 -0500, David Miller a =C3=A9crit=
 :

> I fully support bringing this thing back to life :-)

I'll make extensive tests today and provide two patches when ready, wit=
h
all performance results.

Some prefetch() calls will be removed, since build_skb() provides
already cache hot skb.

Thanks
