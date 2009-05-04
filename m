From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Wrong network usage reported by /proc
Date: Mon, 04 May 2009 19:53:54 +0200
Message-ID: <49FF2BB2.4030700@cosmosbay.com>
References: <20090504171408.3e13822c@python3.es.egwn.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39713 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbZEDRyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 13:54:00 -0400
In-Reply-To: <20090504171408.3e13822c@python3.es.egwn.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthias Saou a =E9crit :
> Hi,
>=20
> I'm posting here as a last resort. I've got lots of heavily used RHEL=
5
> servers (2.6.18 based) that are reporting all sorts of impossible
> network usage values through /proc, leading to unrealistic snmp/cacti
> graphs where the outgoing bandwidth used it higher than the physical
> interface's maximum speed.
>=20
> For some details and a test script which compares values from /proc
> with values from tcpdump :
> https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
>=20
> The values collected using tcpdump always seem realistic and match th=
e
> values seen on the remote network equipments. So my obvious conclusio=
n
> (but possibly wrong given my limited knowledge) is that something is
> wrong in the kernel, since it's the one exposing the /proc interface.
>=20
> I've reproduced what seems to be the same problem on recent kernels,
> including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right now. T=
he
> simple python script available here allows to see it quite easily :
> https://www.redhat.com/archives/rhelv5-list/2009-February/msg00166.ht=
ml
>=20
>  * I run the script on my Workstation, I have an FTP server enabled
>  * I download a DVD ISO from a remote workstation : The values match
>  * I start ping floods from remote workstations : The values reported
>    by /proc are much higher than the ones reported by tcpdump. I used
>    "ping -s 500 -f myworkstation" from two remote workstations
>=20
> If there's anything flawed in my debugging, I'd love to have someone
> point it out to me. TIA to anyone willing to have a look.
>=20
> Matthias
>=20

I could not reproduce this here... what kind of NIC are you using on
affected systems ? Some ethernet drivers report stats from card itself,
and I remember seeing some strange stats on some hardware, but I cannot
remember which one it was (we were reading NULL values instead of
real ones, once in a while, maybe it was a firmware issue...)



