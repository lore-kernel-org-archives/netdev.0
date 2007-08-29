From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 23:13:53 +0200
Message-ID: <46D5E191.6070401@cosmosbay.com>
References: <200708292052.NAA21975@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60125 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbXH2VOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 17:14:06 -0400
In-Reply-To: <200708292052.NAA21975@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
> Enable configuration of the minimum TCP Retransmission Timeout via
> a new sysctl "tcp_rto_min" to help those who's networks (eg cellular)
> have quite variable RTTs avoid spurrious RTOs.
>=20
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> Signed-off-by: Lamont Jones <lamont@hp.com>
> ---
>=20
> diff -r 1559df81a153 include/linux/sysctl.h
> --- a/include/linux/sysctl.h	Mon Aug 13 05:00:33 2007 +0000
> +++ b/include/linux/sysctl.h	Wed Aug 22 10:42:55 2007 -0700
> @@ -441,6 +441,7 @@ enum
>  	NET_TCP_ALLOWED_CONG_CONTROL=3D123,
>  	NET_TCP_MAX_SSTHRESH=3D124,
>  	NET_TCP_FRTO_RESPONSE=3D125,
> +	NET_TCP_RTO_MIN=3D126,
>  };
> =20
>  enum {

I am sure you can use CTL_UNNUMBERED instead of adding yet another sysc=
tl=20
value, as advised in include/linux/sysctl.h

**  For new interfaces unless you really need a binary number
**  please use CTL_UNNUMBERED.


Thank you

