From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP/UDP encapsulation
Date: Thu, 08 Apr 2010 12:29:33 +0200
Message-ID: <1270722573.2215.47.camel@edumazet-laptop>
References: <20100408074247.GA19798@vigoh>
	 <20100408191831.08cd8d7b@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>, netdev@vger.kernel.org,
	marco bonola <marco.bonola@gmail.com>,
	"ZioPRoTo (Saverio Proto)" <zioproto@gmail.com>,
	Behling Mario <mb@mariobehling.de>,
	"L. Aaron Kaplan" <aaron@lo-res.org>
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:60007 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab0DHK3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 06:29:39 -0400
Received: by bwz1 with SMTP id 1so1647463bwz.21
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 03:29:36 -0700 (PDT)
In-Reply-To: <20100408191831.08cd8d7b@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 19:18 +0930, Mark Smith a =C3=A9crit :
> On Thu, 8 Apr 2010 04:42:47 -0300
> "Gustavo F. Padovan" <gustavo@padovan.org> wrote:
>=20
> > Hi,
> >=20
> > I'm looking for some advice on that work. The Freifunk organization=
 is
> > planning work on the IP/UDP encapsulation kernel module as a GSoC
> > project. The idea is to create a IP-in-UDP tunnel like we do for
> > IP-in-IP or IP-in-GRE tunnels. The only way to do that today is to =
use
> > some VPN software.
> >=20
> > The module will export its virtual interface through sockets and wi=
ll
> > have support for the standard syscalls like the others encapsulatio=
n
> > modules.
> >=20
> > It will improve the performance of mesh networks that will we be ab=
le
> > to use IP-in-UDP rather than IP-in-IP.
>=20
> I'm a bit confused. How can tunnelling IP in UDP in IP be faster than=
 IP in IP?
>=20

Maybe the 'gateway' doesnt handle IPIP at all ;)

Until 2.6.32, IPIP tunnels were not so scalable then UDP (RCU enabled)
ipip_rcv() was hitting a global rwlock

git describe 8f95dd63a2ab6fe7243c4f0bd2c3266e3a5525ab
v2.6.32-rc3-468-g8f95dd6



