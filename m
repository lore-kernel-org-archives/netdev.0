From: Harald Welte <laforge@netfilter.org>
Subject: Re: Billing 3: WAS(Re: [PATCH 2/4] deferred drop, __parent workaround, reshape_fail , netdev@oss.sgi.com ,
Date: Tue, 24 Aug 2004 20:46:36 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040824184636.GO26877@sunbeam.de.gnumonks.org>
References: <411C0FCE.9060906@crocetta.org> <1092401484.1043.30.camel@jzny.localdomain> <20040816072032.GH15418@sunbeam2> <1092661235.2874.71.camel@jzny.localdomain> <4120D068.2040608@crocetta.org> <1092743526.1038.47.camel@jzny.localdomain> <41220AEA.20409@crocetta.org> <1093191124.1043.206.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dsOl/BEZn+65LpCE"
Cc: sandr8 <sandr8_NOSPAM_@crocetta.org>, devik@cdi.cz, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1093191124.1043.206.camel@jzny.localdomain>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--dsOl/BEZn+65LpCE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 22, 2004 at 12:12:04PM -0400, jamal wrote:
> On Tue, 2004-08-17 at 09:40, sandr8 wrote:
> > jamal wrote:
>=20
> >=20
> > >Yes, this is a hard question. Did you see the suggestion i proposed
> > >to Harald?
> > > =20
> > >
> > if it is the centralization of the stats with the reason code that,
> > for what concerns the ACCT, says wheter to bill or unbill i
> > think it is _really_ great :)
> > still, for what concerns the multiple interface delivery of the
> > same packet i don't see how it would be solved...
>=20
> Such packets are cloned or copied. I am going to assume the contrack
> data remains intact in both cases. LaForge?

Yes. But still it is a question of viewpoint what kind of behaviour is
correct.  Let's say a single packet is accounted in ct_acct, and then
sent to multiple interfaces, where on more than one of them it gets
unbilled.  So we add once, but 'unbill' (i prefer the term subtract)
more than once.   In the end the ct_acct counter will be less than when
it first encountered the packet.

> In the future we should make accounting a feature that could be turned
> on despite contracking and skbs should carry an accounting metadata with
> them.=20

I don't really understand what you want to say.  You want accounting
that is not conntrack-based?  well, then you should maybe look at
one of the many methods, ranging from iptables rule counters to the ipt_acc=
t match/target, nacctd, pcap-mmap, PF_RING, ULOG-based, ...

btw, they all account the amount of RX packet on inbound interface and
do not 'unbill' ;)

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--dsOl/BEZn+65LpCE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBK40MXaXGVTD0i/8RApHRAKCkt2kS0F9JoAHYtzbIqcynD8NJhACeMfyt
DHIoInreEpH9ib3We5AXGk0=
=u83r
-----END PGP SIGNATURE-----

--dsOl/BEZn+65LpCE--
