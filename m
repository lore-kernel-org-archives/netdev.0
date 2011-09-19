From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG net-next] lost bnx2x
Date: Mon, 19 Sep 2011 14:38:49 +0200
Message-ID: <1316435929.2539.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316406760.2521.18.camel@edumazet-laptop>
	 <1316433250.4154.3.camel@lb-tlvb-dmitry>
	 <1316433920.2539.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:50115 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756Ab1ISMil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 08:38:41 -0400
Received: by ewy28 with SMTP id 28so596489ewy.4
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 05:38:40 -0700 (PDT)
In-Reply-To: <1316433920.2539.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 14:05 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le lundi 19 septembre 2011 =C3=A0 14:54 +0300, Dmitry Kravkov a =C3=A9=
crit :
> > On Sun, 2011-09-18 at 21:32 -0700, Eric Dumazet wrote:
> > > With latest net-next, my bnx2x doesnt start
> > >=20
> > > bnx2x: Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw
> > >=20
> > > But I do have the file in /lib/firmware/bnx2x/bnx2x-e1h-7.0.23.0.=
fw
> > >=20
> >=20
> > Just pulled net-next - bnx2x device can load and pass traffic(on x8=
6-64)
> > Can you provide more details about your setup?
>=20
> Please hold on, it might be because of my af_unix patches.
>=20
> I am investigating right now.
>=20
>=20

Yes, it appears that udevd relies on receiving CREDENTIAL in af_unix
messages.

Sorry for the false alarm, bnx2x works well once udevd is functional.
