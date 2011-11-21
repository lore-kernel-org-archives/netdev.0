From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: MPLS for Linux kernel
Date: Mon, 21 Nov 2011 20:18:52 +0100
Message-ID: <4ECAA41C.9040007@dti2.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com> <4ECA67C6.2080802@dti2.net> <20111121.132914.1611617296397809001.davem@davemloft.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:53484 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756063Ab1KUTTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:19:00 -0500
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764004.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 20:18:57 +0100
In-Reply-To: <20111121.132914.1611617296397809001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 21/11/2011 19:29, David Miller escribi=F3:
> From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
> Date: Mon, 21 Nov 2011 16:01:26 +0100
>=20
>> 	mpls-linux it is not ready to go upstream in my opinion.
>=20
> And can arguably be implemented in terms of openvswitch and packet sc=
heduler actions.

	I guess so, I have not really looked much at the openvswitch code. The=
 MPLS
code it is pretty self contained and in my opinion more tied to routing=
 than to
switching (*). I don't think it should be necessary an userspace daemon=
, like it
seems necessary for openvswitch, just to bind a label to a route, the s=
ame way
that it is not necessary a daemon to support VLAN's currently. The labe=
l
signaling protocols are already complicated :)

	I work in this code, like a lot of people do, because I have a use for=
 it. I
would really like to see it upstreamed but if it does not fit upstream =
plans, it
is not a problem, this code it is not that hard to maintain.

	In any case critics/reviews/patches are most than welcome.

(*) The code that you implemented for 2.6.1 and that James R. Leu used =
in this
codebase it is even more tied together to routing.
