From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: MPLS for Linux kernel
Date: Mon, 21 Nov 2011 18:46:20 +0100
Message-ID: <4ECA8E6C.5020701@dti2.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com> <4ECA67C6.2080802@dti2.net> <20111121091711.1be69369@nehalam.linuxnetplumber.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs,
	Linux Network Development list <netdev@vger.kernel.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:62836 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab1KURqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 12:46:23 -0500
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019762310.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 18:46:20 +0100
In-Reply-To: <20111121091711.1be69369@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 21/11/2011 18:17, Stephen Hemminger escribi=C3=B3:
> On Mon, 21 Nov 2011 16:01:26 +0100
> "Jorge Boncompte [DTI2]" <jorge@dti2.net> wrote:
>=20
>> El 20/11/2011 22:59, Igor Maravi=C4=87 escribi=C3=B3:
>>> Hi all,
>>> I've been working on implementation of MPLS for Linux kernel, for a
>>> some time now.
>>> I continued the work of James Leu
>>> (https://sourceforge.net/projects/mpls-linux/) and used some fixes =
of
>>> Jorge Boncompte
>>> (http://mpls-linux.git.sourceforge.net/git/gitweb.cgi?p=3Dmpls-linu=
x/net-next;a=3Dshortlog;h=3Drefs/heads/net-next-mpls).
>>>
>>> I fixed a lot of bugs, so now it can be compiled and run with all
>>> Kernel Hacking options enabled.
>>> My code could be found on this sites:
>>>
>>> https://github.com/i-maravic/MPLS-Linux
>>> https://github.com/i-maravic/iproute2
>>>
>>> Any feedback is appreciated :)
>>
>> 	Provide, clean, separated, and commented changes to the upstream pr=
oject as we
>> have asked you several times to do.
>>
>> 	mpls-linux it is not ready to go upstream in my opinion.
>=20
> Out of tree is out of mind. Very few developers will bother with
> a kernel component not in the mainline tree.

	Yes, I am well aware of it. I've been cleaning the code, as time permi=
ts, with
the intention of trying to submit it.

>=20
> Staging?

	I have not really looked at it but I thought that staging is only for =
drivers?
The mpls-linux code has some (little) hooks in the core networking stuf=
f but I
think that maybe we can remove them and make it almost stand alone.

	I would be more than happy to move the code out of the shadows.

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- There is only so much duct tape you can put on something
  before it just becomes a giant ball of duct tape.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
