From: Frederic Leroy <fredo@starox.org>
Subject: scp stalls mysteriously
Date: Fri, 27 Nov 2009 22:35:45 +0100
Message-ID: <20091127223545.2a752429@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>,
	Asdo <asdo@shiftmail.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:40525 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbZK0Vgc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 16:36:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo,

I put traces of stall here :=20
http://www.starox.org/pub/scp_stall/

openssh versions :=20

houba tmp # equery l openssh
[ Searching for package 'openssh' in all categories among: ]
 * installed packages
[I--] [  ] net-misc/openssh-5.2_p1-r3 (0)

fredo@sg:~$ dpkg -l | grep ssh
ii  libssh2-1                         0.18-1                    SSH2 cl=
ient-side library
ii  openssh-blacklist                 0.4.1                     list of=
 default blacklisted OpenSSH RSA and=20
ii  openssh-client                    1:5.1p1-5                 secure =
shell client, an rlogin/rsh/rcp repla
ii  openssh-server                    1:5.1p1-5                 secure =
shell server, an rshd replacement
ii  ssh                               1:5.1p1-5                 secure =
shell client and server (metapackage)

I will downgrade gentoo ssh and give another try ...

--=20
=46r=C3=A9d=C3=A9ric Leroy
