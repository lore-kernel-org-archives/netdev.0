From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Fri, 27 Nov 2009 23:22:57 +0100
Message-ID: <20091127232257.1c13ccde@houba>
References: <20091127223545.2a752429@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	"Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>,
	Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:41534 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbZK0WXP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:23:15 -0500
In-Reply-To: <20091127223545.2a752429@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Fri, 27 Nov 2009 22:35:45 +0100,
=46rederic Leroy <fredo@starox.org> a =C3=A9crit :
> openssh versions :=20
>=20
> houba tmp # equery l openssh
> [ Searching for package 'openssh' in all categories among: ]
>  * installed packages
> [I--] [  ] net-misc/openssh-5.2_p1-r3 (0)
>=20
> fredo@sg:~$ dpkg -l | grep ssh
> ii  libssh2-1                         0.18-1                    SSH2
> client-side library ii  openssh-blacklist
> 0.4.1                     list of default blacklisted OpenSSH RSA and
> ii  openssh-client                    1:5.1p1-5
> secure shell client, an rlogin/rsh/rcp repla ii
> openssh-server                    1:5.1p1-5                 secure
> shell server, an rshd replacement ii
> ssh                               1:5.1p1-5                 secure
> shell client and server (metapackage)
>=20
> I will downgrade gentoo ssh and give another try ...

Argh !!!=20

I emerged openssh-5.1_p1-r2 on houba.
Restarted ssh server (/etc/init.d/sshd restart)
Log on sg and make a scp as usual.=20
It worked fine.
Make a second copy, and It worked fine also.

Then, I emerged openssh-5.2_p1-r3 on houba, restarted sshd, make three
big copies ... and finally it worked fine.=20

The bug mysteriously escaped from the dungeon !

--=20
=46r=C3=A9d=C3=A9ric Leroy
