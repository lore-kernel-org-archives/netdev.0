From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH]: Make XFRM_ACQ_EXPIRES tweakable
Date: Fri, 25 May 2007 07:17:40 +0200
Message-ID: <46567174.5020509@cosmosbay.com>
References: <20070524.221304.36926453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43069 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbXEYFRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 01:17:50 -0400
In-Reply-To: <20070524.221304.36926453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> I've had several requests for the capability to change this
> timeout, which I think is perfectly reasonable.
>=20
> So I intend to merge the following upstream unless I hear
> some objections :-)
>=20
> commit 7191f131aff4797f2a906495c7b285d8adf47da2
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Thu May 24 21:28:00 2007 -0700
>=20
>     [XFRM]: Allow XFRM_ACQ_EXPIRES to be tunable via sysctl.
>    =20
>     Signed-off-by: David S. Miller <davem@davemloft.net>

well :)

>=20
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -33,6 +33,8 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_etime);
>  u32 sysctl_xfrm_aevent_rseqth =3D XFRM_AE_SEQT_SIZE;
>  EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth);
> =20
> +u32 sysctl_xfrm_acq_expires =3D 30;
> +

You already knows what is my objection :)


