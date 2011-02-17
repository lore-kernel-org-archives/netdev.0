From: Andreas Fenkart <afenkart@gmail.com>
Subject: Re: [PATCH 1/1] ARC VMAC ethernet driver.
Date: Thu, 17 Feb 2011 09:26:50 +0000
Message-ID: <AANLkTi=5XOmzzO=Bov4Rse_rhw_0uPnjPNN1DN9CLSXX@mail.gmail.com>
References: <20101208.090040.39174008.davem@davemloft.net>
	<1297762288-9263-1-git-send-email-afenkart@gmail.com>
	<1297764149.3201.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62120 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab1BQJ0w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 04:26:52 -0500
Received: by fxm20 with SMTP id 20so2377023fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 01:26:51 -0800 (PST)
In-Reply-To: <1297764149.3201.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fixed, pls find new version in reply to this mail.

2011/2/15 Eric Dumazet <eric.dumazet@gmail.com>:
> Le mardi 15 f=E9vrier 2011 =E0 10:31 +0100, Andreas Fenkart a =E9crit=
 :
>> Signed-off-by: Andreas Fenkart <afenkart@gmail.com>
>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 processed++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D dev;
> =A0 =A0 =A0 =A0eth_type_trans() already sets "skb->dev =3D dev;"
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->protocol =3D eth_type_trans(skb, dev)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ap->stats.rx_packets++;
> Hmm, why dont you use dev->stats internal structure ? No need to
> maintain a shadow in ap->stats.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 ap->stats.rx_bytes +=3D skb->len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev->last_rx =3D jiffies;
> =A0 =A0 =A0 =A0/* last_rx =3D jiffies; not needed anymore =A0*/
>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
>
> A NAPI driver should use netif_receive_skb(), not netif_rx()
>
>
>
>
