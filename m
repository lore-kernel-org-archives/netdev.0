From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH net-next-2.6 v2] net: ping: dont call udp_ioctl()
Date: Mon, 16 May 2011 16:48:28 +0400
Message-ID: <20110516124828.GA5943@albatros>
References: <1305447520.3120.88.camel@edumazet-laptop>
 <20110515213018.GA26820@openwall.com>
 <20110515.174430.1379973540554096232.davem@davemloft.net>
 <1305530791.3120.217.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, solar@openwall.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peak@argo.troja.mff.cuni.cz, kees.cook@canonical.com,
	dan.j.rosenberg@gmail.com, eugene@redhat.com, nelhage@ksplice.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305530791.3120.217.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2011 at 09:26 +0200, Eric Dumazet wrote:
> Le dimanche 15 mai 2011 =E0 17:44 -0400, David Miller a =E9crit :
>=20
> > Just get rid of ping_ioctl() entirely, as that is the effect of
> > this change since inet_ioctl() returns -ENOIOCTLCMD when
> > sk_prot->ioctl is NULL.
> >=20
> > Also get rid of asm/ioctls.h since that will be no longer needed.
>=20
> Sure, here is updated version, thanks.
>=20
> [PATCH net-next-2.6 v2] net: ping: dont call udp_ioctl()
>=20
> udp_ioctl() really handles UDP and UDPLite protocols.
>=20
> 1) It can increment UDP_MIB_INERRORS in case first_packet_length() fi=
nds
> a frame with bad checksum.
>=20
> 2) It has a dependency on sizeof(struct udphdr), not applicable to
> ICMP/PING
>=20
> If ping sockets need to handle SIOCINQ/SIOCOUTQ ioctl, this should be
> done differently.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Vasiliy Kulikov <segoon@openwall.com>

Thanks,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environ=
ments
