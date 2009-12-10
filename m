From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gianfar: Fix stats support
Date: Thu, 10 Dec 2009 09:21:58 +0100
Message-ID: <4B20AFA6.80706@gmail.com>
References: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com> <4B209173.7030304@gmail.com> <9F4C7D19E8361D4C94921B95BE08B81BA08AE5@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, avorontsov@ru.mvista.com,
	davem@davemloft.net
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45766 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760733AbZLJIWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:22:19 -0500
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA08AE5@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 08:43, Kumar Gopalpet-B05799 a =E9crit :
> =20
>> Fine by me, but if this patch is for linux-2.6.33, you can use=20
>> dev_txq_stats_fold() helper in your gfar_get_stats()
>>
>> dev_txq_stats_fold(dev, &dev->stats);
>> return &dev->stats;
>>
>=20
> Eric, the problem in using dev_txq_stats_fold() will be that
> txq->tx_dropped will not be updated. tx_dropped counter is updated on=
 a
> device level in the gfar_error( ) interrupt context (here we do not k=
now
> the txq index).
> So, if we use dev_txq_stats_fold(), we will incorrectly give the
> tx_dropped stats.

Ah yes, you are very right, thanks !
