From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Fri, 03 Feb 2012 10:00:40 +0100
Message-ID: <1328259640.2480.43.camel@edumazet-laptop>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>
	 <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A823733349A5D2-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 07:18 +0000, Hefty, Sean a =C3=A9=
crit :
> > Hi Sean, this is the patch posted earlier by Eric enhanced to
> > have IPoIB to set gro_mac_header_len to the ipoib header len, does
> > it make things to work okay for you?
>=20
> I ran a quick test.  It helps some, but the performance for streaming=
 packets in one direction is still only 0.11 Gbps.  It should be closer=
 to 10-15 Gbps for ipoib on my systems.
>=20
> - Sean

Hmm... a tcpdump would help to understand what is going on (for example
if GRO kicks in)



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
