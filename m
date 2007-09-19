From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: RE: [ofa-general] [PATCH] RDMA/CMA: Implement rdma_resolve_ip retry
	enhancement.
Date: Wed, 19 Sep 2007 18:45:28 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC076E400D@venom2>
References: <200709190022.l8J0MbWt024754@neteffect.com>
	<46F153C4.2070008@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: "Sean Hefty" <mshefty@ichips.intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <46F153C4.2070008@ichips.intel.com>
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

> > If an application is calling rdma_resolve_ip() and a status=20
> of -ENODATA is returned from addr_resolve_local/remote(), the=20
> timeout mechanism waits until the application's timeout=20
> occurs before rechecking the address resolution status; the=20
> application will wait until it's full timeout occurs.  This=20
> case is seen when the work thread call to process_req() is=20
> made before the arp packet is processed.
>=20
> I don't understand the issue.  process_req() is invoked whenever a=20
> network event occurs, which rechecks all pending requests.

Yes, I see the netevent_callback().  I now agree that this patch is not
necessary.

Roland, please disregard.

Glenn.
=20
>=20
> > This patch is in addition to Steve Wise's neigh_event_send=20
> patch to initiate neighbour discovery sent on 9/12/2007.
>=20
> This patch looks unrelated to Steve's patch.  Can you clarify the=20
> relationship?
>=20
> - Sean
>=20
