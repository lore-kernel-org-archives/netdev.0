From: =?UTF-8?B?SmFyZWsgS2FtacWEc2tp?= <jarek@vilo.eu.org>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Tue, 11 Jan 2011 19:21:28 +0100
Message-ID: <4D2C9FA8.7010401@vilo.eu.org>
References: <20110110131439.GA663@rocket.almost.secure.la> <1294724952.3235.2.camel@localhost> <4D2C06CF.4090507@vilo.eu.org> <20110111132524.GA2479@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 609538@bugs.debian.org,
	Hayes Wang <hayeswang@realtek.com>,
	netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vilo.eu.org ([80.52.229.66]:37907 "EHLO vilo.eu.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab1AKSVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 13:21:32 -0500
In-Reply-To: <20110111132524.GA2479@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 11.01.2011 14:25, Francois Romieu pisze:
> Jarek Kami=C5=84ski <jarek@vilo.eu.org> :
> [...]
>> The last 2.6.36 I've tried was 2.6.36-1~experimental.1, I've then
>> passsed and returned to 2.6.32 for unrelated problems. I think it wa=
sn't
>> affected, but I can re-check it and/or test later 2.6.36 versions if=
 it
>> may help.
>=20
> The patch below against 2.6.37-git + davem's pending fixes (see
> http://marc.info/?l=3Dlinux-netdev&m=3D129448910825754) should help.
>=20
> Can you give it a try ?
>=20
> r8169: keep firmware in memory.

This patch applied against current git tree fixes problem (with firmwar=
e
installed). However, cherry-picking
eee3a96c6368f47df8df5bd4ed1843600652b337 (r8169: delay phy init until
device opens.) from net-2.6.git and applying "r8169: keep firmware in
memory." still results with
#v+
Jan 11 19:05:18 rocket kernel: [  673.176439] ata1.00: configured for
UDMA/100
Jan 11 19:05:18 rocket kernel: [  731.639054] r8169 0000:13:00.0: eth0:
unable to apply firmware patch
Jan 11 19:05:18 rocket kernel: [  731.640486] PM: resume of devices
complete after 60228.033 msecs
#v-
(I don't fully understand why)

"r8169: delay phy init until device opens." alone also doesn't do the t=
rick.

--=20
pozdr(); // Jarek
