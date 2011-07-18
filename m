From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Mon, 18 Jul 2011 12:55:17 +0300
Message-ID: <1310982917.8205.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <201106141213.34576.vladz@broadcom.com>
 <BD3F7F1EFBA6D54DB056C4FFA451400809D2C13864@SJEXCHCCR01.corp.ad.broadcom.com>
 <201106141432.32257.vladz@broadcom.com>
 <20110614.115402.426774711287563448.davem@davemloft.net>
 <1310982501.5756.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Bhanu (Venkata Bhanu Prakash) Gollapudi" <bprakash@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2353 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab1GRJzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 05:55:35 -0400
In-Reply-To: <1310982501.5756.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-07-18 at 02:48 -0700, Eric Dumazet wrote:
> Le mardi 14 juin 2011 =C3=A0 11:54 -0400, David Miller a =C3=A9crit :
> > From: "Vlad Zolotarov" <vladz@broadcom.com>
> > Date: Tue, 14 Jun 2011 14:32:31 +0300
> >=20
> > > We also send the new FW files to David Woodhouse. It's the first =
time we
> > > submit to the linux-firmware git so I hope we don't mess the thin=
gs up: we
> > > DO NOT patch firmware/WHENCE and firmware/Makefile files in our n=
et-next
> > > patches and we patch the WHENCE file in the linux-firmware patch.=
 Dave,
> > > pls., confirm if it's a correct procedure.
> > >=20
> > > If it is, pls., note that the bnx2x driver will compile but won't=
 work
> > > until u integrate the new FW into the kernel tree.
> >=20
> > David Woodhouse, what do you think we should do here?
> >=20
> > I'm inclined to integrate the firmware into net-next-2.6 since this
> > is the only way to keep the driver working consistently.
> >=20
> > Otherwise people won't be able to git bisect properly, and that suc=
ks.
>=20
>=20
> Hmm, I probably missed something obvious, but my dev machine (one HPG=
6
> blade in a distant datacenter) fails to init its bnx2x interfaces wit=
h
> current net-next-2.6
>=20
> Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw

You are missing the FW git from
git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git

You need to get it separately since the FW is not part of the kernel gi=
t
now.

Regards,
Eilon




