From: "Felix Marti" <felix@chelsio.com>
Subject: RE: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Sun, 19 Aug 2007 18:45:24 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334018E20C2@maui.asicdesigners.com>
References: <000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com><20070819.002337.06589160.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E208F@maui.asicdesigners.com><20070819.123212.13769462.davem@davemloft.net><8A71B368A89016469F72CD08050AD334018E209C@maui.asicdesigners.com>
	<p73hcmv14wo.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
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
> Sent: Sunday, August 19, 2007 4:28 PM
> To: Felix Marti
> Cc: David Miller; jeff@garzik.org; netdev@vger.kernel.org;
> rdreier@cisco.com; linux-kernel@vger.kernel.org;
> general@lists.openfabrics.org
> Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
> PS_TCPportsfrom the host TCP port space.
>=20
> "Felix Marti" <felix@chelsio.com> writes:
>=20
> > what benefits does the TSO infrastructure give the
> > non-TSO capable devices?
>=20
> It improves performance on software queueing devices between guests
> and hypervisors. This is a more and more important application these
> days.  Even when the system running the Hypervisor has a non TSO
> capable device in the end it'll still save CPU cycles this way. Right
> now
> virtualized IO tends to much more CPU intensive than direct IO so any
> help it can get is beneficial.
>=20
> It also makes loopback faster, although given that's probably not that
> useful.
>=20
> And a lot of the "TSO infrastructure" was needed for zero copy TX
> anyways,
> which benefits most reasonable modern NICs (anything with hardware
> checksumming)
Hi Andi, yes, you're right. I should have chosen my example more
carefully.

>=20
> -Andi
