From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/2] net: dsa: introduce STPID switch
	tagging handling code
Date: Wed, 21 Jul 2010 11:29:30 -0400
Message-ID: <AANLkTim1gbnH99GC_dVL8uevRgCRsn7dvAJ_rX-2Xgon@mail.gmail.com>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<20100721150251.GL21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karl Beldan <karl.beldan@gmail.com>, netdev@vger.kernel.org,
	Graf Yang <graf.yang@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33348 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab0GUP3w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 11:29:52 -0400
Received: by wwj40 with SMTP id 40so2467256wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 08:29:50 -0700 (PDT)
In-Reply-To: <20100721150251.GL21121@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 21, 2010 at 11:02, Lennert Buytenhek wrote:
> On Wed, Jul 21, 2010 at 09:37:21AM -0400, Mike Frysinger wrote:
>> + =C2=A0 =C2=A0 source_port =3D dsa_header[1] & 0x03;
>> + =C2=A0 =C2=A0 if (source_port >=3D DSA_MAX_PORTS || ds->ports[sour=
ce_port] =3D=3D NULL)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_drop;
>> +
>> + =C2=A0 =C2=A0 if (((dsa_header[0] & ETH_P_8021QH) =3D=3D ETH_P_802=
1QH) &&
>
> This is bogus -- what it does is:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((dsa_header[0] & 0x81) =3D=3D 0x81)
>
> It doesn't look like you need to mask here at all.

where does it say dsa_header[0] will always have 0x81 set ?
-mike
