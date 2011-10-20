From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 15:11:17 +0200
Message-ID: <1319116277.7735.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
	 <1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jonsmirl@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50917 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028Ab1JTNLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 09:11:21 -0400
Received: by yxl42 with SMTP id 42so198728yxl.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 06:11:21 -0700 (PDT)
In-Reply-To: <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 16:50 +0400, Alexander Smirnov a =C3=A9=
crit :
> Hi Eric,
>=20
> thank you for the replies. And another question I forgot to ask:
>=20
> when I send fragments, I still have original skb buffer. What should =
I
> do with it, is there any
> "proper/good" ways to drop it? Because I've already fragmented it and
> do not need to send
> original skb to queue.

I dont quite understand. Once your xmits are done, you must free the
original skb.
