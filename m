From: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3:
	Support"iwarp-only"interfacestoavoid 4-tuple conflicts.
Date: Mon, 1 Oct 2007 08:34:42 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB80518780A@exnane01.hq.netapp.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com><C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com><000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com><C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com><46FD5A2F.7010409@opengridcomputing.com><C98692FD98048C41885E0B0FACD9DFB805187762@exnane01.hq.netapp.com>
	<46FD7380.6050107@ichips.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Sean Hefty" <mshefty@ichips.intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <46FD7380.6050107@ichips.intel.com>
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

Sean,
Not so simple.
How does client application knows where to connect?
Does this proposal forces applications to choose
the "right" network?
Currently, MPA or ULP and not applications handle it.
Why would we want to change that?

Sean,
I may be beating the dead horse,
but I recall that one of the main selling points
of RDMA that it magical bust to performance with
no changes applications. Just plug it in an viola,
performances goes up and CPU utilization for network
stack goes does. Win-Win.

Thanks,

Arkady Kanevsky                       email: arkady@netapp.com
Network Appliance Inc.               phone: 781-768-5395
1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
Waltham, MA 02451                   central phone: 781-768-5300
=20

> -----Original Message-----
> From: Sean Hefty [mailto:mshefty@ichips.intel.com]=20
> Sent: Friday, September 28, 2007 5:35 PM
> To: Kanevsky, Arkady
> Cc: netdev@vger.kernel.org; rdreier@cisco.com;=20
> linux-kernel@vger.kernel.org; general@lists.openfabrics.org
> Subject: Re: [ofa-general] [PATCH v3] iw_cxgb3:=20
> Support"iwarp-only"interfacestoavoid 4-tuple conflicts.
>=20
> Kanevsky, Arkady wrote:
> > Exactly,
> > it forces the burden on administrator.
> > And one will be forced to try one mount for iWARP and it=20
> does not work=20
> > issue another one TCP or UDP if it fails.
> > Yack!
> >=20
> > And server will need to listen on different IP address and simple
> > * will not work since it will need to listen in two=20
> different domains.
>=20
> The server already has to call listen twice.  Once for the=20
> rdma_cm and once for sockets.  Similarly on the client side,=20
> connect must be made over rdma_cm or sockets.  I really don't=20
> see any impact on the application for this approach.
>=20
> We just end up separating the port space based on networking=20
> addresses, rather than keeping the problem at the transport=20
> level.  If you have an alternate approach that will be=20
> accepted upstream, feel free to post it.
>=20
> - Sean
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>=20
> To unsubscribe, please visit=20
> http://openib.org/mailman/listinfo/openib-general
>=20
