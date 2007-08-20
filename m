From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Mon, 20 Aug 2007 12:02:25 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E2149@maui.asicdesigners.com>
References: <20070819.174017.77241227.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com><20070820094317.GA14817@2ka.mipt.ru><8A71B368A89016469F72CD08050AD334018E2115@maui.asicdesigners.com>
	<p73y7g6yt3j.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, jeff@garzik.org,
	netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: ak@suse.de [mailto:ak@suse.de] On Behalf Of Andi Kleen
> Sent: Monday, August 20, 2007 11:11 AM
> To: Felix Marti
> Cc: Evgeniy Polyakov; jeff@garzik.org; netdev@vger.kernel.org;
> rdreier@cisco.com; linux-kernel@vger.kernel.org;
> general@lists.openfabrics.org; David Miller
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> "Felix Marti" <felix@chelsio.com> writes:
>=20
> > What I was referring to is that TSO(/LRO) have their own
> > issues, some eluded to by Roland and me. In fact, customers working
> on
> > the LSR couldn't use TSO due to the burstiness it introduces
>=20
> That was in old kernels where TSO didn't honor the initial cwnd
> correctly,
> right? I assume it's long fixed.
>=20
> If not please clarify what the problem was.
The problem is that is that Ethernet is about the only technology that
discloses 'useable' throughput while everybody else talks about
signaling rates ;) - OC-192 can carry about 9.128Gbps (or close to that
number) and hence 10Gbps Ethernet was overwhelming the OC-192 network.
The customer needed to schedule packets at about 98% of OC-192
throughput in order to avoid packet drop. The scheduling needed to be
done on a per packet basis and not per 'burst of packets' basis in order
to avoid packet drop.
=20
>=20
> > have a look at graphics.
> > Graphics used to be done by the host CPU and now we have dedicated
> > graphics adapters that do a much better job...
>=20
> Is your off load device as programable as a modern GPU?
It has a lot of knobs to turn.

>=20
> > farfetched that offload devices can do a better job at a data-flow
> > problem?
>=20
> One big difference is that there is no potentially adverse and
> always varying internet between the graphics card and your monitor.
These graphic adapters provide a wealth of features that you can take
advantage of to bring these amazing graphics to life. General purpose
CPUs cannot keep up. Chelsio offload devices do the same thing in the
realm of networking. - Will there be things you can't do, probably yes,
but as I said, there are lots of knobs to turn (and the latest and
greatest feature that gets hyped up might not always be the best thing
since sliced bread anyway; what happened to BIC love? ;)

>=20
> -Andi
