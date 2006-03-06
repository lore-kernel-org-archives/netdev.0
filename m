From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 2/6] IB: match connection requests
 based on private data
Date: Mon, 6 Mar 2006 11:20:57 -0800
Message-ID: <54AD0F12E08D1541B826BE97C98F99F12FBF19@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
To: "Sean Hefty" <sean.hefty@intel.com>,
	"Roland Dreier" <rdreier@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

=20

> -----Original Message-----
> From: netdev-owner@vger.kernel.org=20
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Sean Hefty
> Sent: Monday, March 06, 2006 11:04 AM
> To: 'Roland Dreier'
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;=20
> openib-general@openib.org
> Subject: [PATCH 2/6] IB: match connection requests based on=20
> private data
>=20
> Extend matching connection requests to listens in the=20
> Infiniband CM to include private data checks.
>=20
> This allows applications to listen on the same service=20
> identifier, with private data directing the request to the=20
> appropriate application.
>=20
> Signed-off-by: Sean Hefty <sean.hefty@intel.com>
>=20

The term "private data" is intended to convey the
intent that the data is private to the application
layer and is opaque to middleware and the network.

By what mechanism does the listening application
delegate how much of the private data for use by
the CM for sub-dividing a listen? What does an=20
application do if it wishes to retain full ownership
of the private data?
