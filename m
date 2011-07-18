From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Mon, 18 Jul 2011 11:48:21 +0200
Message-ID: <1310982501.5756.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201106141213.34576.vladz@broadcom.com>
	 <BD3F7F1EFBA6D54DB056C4FFA451400809D2C13864@SJEXCHCCR01.corp.ad.broadcom.com>
	 <201106141432.32257.vladz@broadcom.com>
	 <20110614.115402.426774711287563448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladz@broadcom.com, mchan@broadcom.com, bprakash@broadcom.com,
	eilong@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com,
	yaniv.rosner@broadcom.com, dwmw2@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33031 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab1GRJsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 05:48:33 -0400
Received: by wyg8 with SMTP id 8so1947939wyg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 02:48:32 -0700 (PDT)
In-Reply-To: <20110614.115402.426774711287563448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 juin 2011 =C3=A0 11:54 -0400, David Miller a =C3=A9crit :
> From: "Vlad Zolotarov" <vladz@broadcom.com>
> Date: Tue, 14 Jun 2011 14:32:31 +0300
>=20
> > We also send the new FW files to David Woodhouse. It's the first ti=
me we
> > submit to the linux-firmware git so I hope we don't mess the things=
 up: we
> > DO NOT patch firmware/WHENCE and firmware/Makefile files in our net=
-next
> > patches and we patch the WHENCE file in the linux-firmware patch. D=
ave,
> > pls., confirm if it's a correct procedure.
> >=20
> > If it is, pls., note that the bnx2x driver will compile but won't w=
ork
> > until u integrate the new FW into the kernel tree.
>=20
> David Woodhouse, what do you think we should do here?
>=20
> I'm inclined to integrate the firmware into net-next-2.6 since this
> is the only way to keep the driver working consistently.
>=20
> Otherwise people won't be able to git bisect properly, and that sucks=
=2E


Hmm, I probably missed something obvious, but my dev machine (one HPG6
blade in a distant datacenter) fails to init its bnx2x interfaces with
current net-next-2.6

Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw



