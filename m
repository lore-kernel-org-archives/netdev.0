From: Romano Giannetti <romanol@upcomillas.es>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Mon, 03 Dec 2007 09:24:15 +0100
Message-ID: <1196670255.4127.21.camel@rukbat>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	 <47515D39.9030900@rtr.ca>	<20071201111736.297dd99a@freepuppy.rosehill>
	 <20071201163035.321fd554@freepuppy.rosehill>  <475227B1.2060802@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antispam.upcomillas.es ([130.206.70.245]:58477 "EHLO
	antispam.upcomillas.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbXLCIoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 03:44:55 -0500
In-Reply-To: <475227B1.2060802@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 2007-12-01 at 22:34 -0500, Mark Lord wrote:
> Stephen Hemminger wrote:.
> >>
> > I spoke too soon earlier, ndiswrapper builds and loads against curr=
ent
> > 2.6.24-rc3. Vmware and proprietary VPN software probably do not. On=
ce again I don't
> > give a damn, but the enterprise distro vendors certainly care.
> ...
>=20
> Naw, enterprise (or any other) distro vendors shouldn't have any issu=
es here,
> since they can just patch their kernels around any issues.

Please pardon me for jumping in; I am not a kernel developer, but I try
to help with debugging whenever I can (and it's not just hand-waving, I
helped to track down a couple of nasty bugs on MMC or ACPI EC,
recently). And I am an engineer and IANAL, so I wouldn't speak about
laws here. But I think it's not just a distribution's problem.

Unfortunately, I need VMware and ndiswrapper to get work done with my
laptop. It's not the perfect world, but the only alternative is to boot
in XP. So I normally stick with vendors kernels and, when I have time t=
o
"play" with new kernel, I go for it. If ndiswrapper and VMware work,
perfect, I can test extensively the new kernel; if I find problems, I
*know* I have to restart without proprietary modules, try to reproduce,
report back. I did it a lot of times.

What I think is that every time VMware or (worst) ndiswrapper breaks,
the kernel loose an awful lot of testers. In the span of time before
Giri and the VMware team post a patch (-rc1 and -rc4, tipically), my
testing activity is just occasional. And I guess a lot of people is in
the same situation.=20

These are just my 2cents. I will continue to test new kernels every tim=
e
I can, and to use native solutions as often as I can (go, ath5k, go!;
and LabWindows/CVI for Linux, anyone?). But maybe a bit of tolerance ca=
n
help everyone...

Back in my hole,

		Romano=20


--=20
Sorry for the disclaimer --- =A1I cannot stop it!



--
La presente comunicaci=F3n tiene car=E1cter confidencial y es para el e=
xclusivo uso del destinatario indicado en la misma. Si Ud. no es el des=
tinatario indicado, le informamos que cualquier forma de distribuci=F3n=
, reproducci=F3n o uso de esta comunicaci=F3n y/o de la informaci=F3n c=
ontenida en la misma est=E1n estrictamente prohibidos por la ley. Si Ud=
=2E ha recibido esta comunicaci=F3n por error, por favor, notif=EDquelo=
 inmediatamente al remitente contestando a este mensaje y proceda a con=
tinuaci=F3n a destruirlo. Gracias por su colaboraci=F3n.

This communication contains confidential information. It is for the exc=
lusive use of the intended addressee. If you are not the intended addre=
ssee, please note that any form of distribution, copying or use of this=
 communication or the information in it is strictly prohibited by law. =
If you have received this communication in error, please immediately no=
tify the sender by reply e-mail and destroy this message. Thank you for=
 your cooperation.=20
