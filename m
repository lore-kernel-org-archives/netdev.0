From: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Subject: RE: [ofa-general] [PATCH 2.6.26 3/3] RDMA/cxgb3: Support
	peer-2-peerconnection setup.
Date: Mon, 28 Apr 2008 09:51:11 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8078B23DC@exnane01.hq.netapp.com>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>	<20080427160010.31018.67436.stgit@dell3.ogc.int><adatzhn2r5z.fsf@cisco.com>
	<4814AD7B.2060006@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Steve Wise" <swise@opengridcomputing.com>,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <4814AD7B.2060006@opengridcomputing.com>
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

I expect it to be tests at Sept interop event.
If it works then I will send proposal to IETF for MPA enhancement.
Thanks,

Arkady Kanevsky                       email: arkady@netapp.com
Network Appliance Inc.               phone: 781-768-5395
1601 Trapelo Rd. - Suite 16.        Fax: 781-895-1195
Waltham, MA 02451                   central phone: 781-768-5300
=20

> -----Original Message-----
> From: Steve Wise [mailto:swise@opengridcomputing.com]=20
> Sent: Sunday, April 27, 2008 12:45 PM
> To: Roland Dreier
> Cc: netdev@vger.kernel.org; general@lists.openfabrics.org;=20
> linux-kernel@vger.kernel.org; divy@chelsio.com
> Subject: Re: [ofa-general] [PATCH 2.6.26 3/3] RDMA/cxgb3:=20
> Support peer-2-peerconnection setup.
>=20
>=20
>=20
> Roland Dreier wrote:
> > What are the interoperability implications of this?
> >=20
> > Looking closer I see that iw_nes has the send_first module=20
> parameter.
> > How does this interact with that?
> >=20
>=20
> It doesn't...yet.  But we wanted to enable these applications=20
> for chelsio now and get the low level fw and driver changes=20
> done first and tested.
>=20
> > I guess it's fine to apply this, but do we have a plan for=20
> how we want=20
> > to handle this issue in the long-term?
> >=20
>=20
> Yes!  If you'll recall, we had a thread on the ofa general=20
> list discussing how to enhance the MPA negotiation so peers=20
> can indicate whether they want/need the RTR and what type of=20
> RTR (0B read, 0B write, or 0B send) should be sent.  This=20
> will be done by standardizing a few bits of the private data=20
> in order to negotiate all this.  The rdma-cma API will be=20
> extended so applications will have to request this=20
> peer-2-peer model since it adds overhead to the connection setup.
>=20
> I plan to do this work for 2.6.27/ofed-1.4.  I think it was=20
> listed in Felix's talk at Sonoma.  This work (design, API,=20
> and code changes affecting core and placing requirements on=20
> iwarp providers) will be posted as RFC changes to get=20
> everyones feedback as soon as I get something going.
>=20
> Does that sound ok?
>=20
>=20
> Steve.
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>=20
> To unsubscribe, please visit=20
> http://openib.org/mailman/listinfo/openib-general
>=20
