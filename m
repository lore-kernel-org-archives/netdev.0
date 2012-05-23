From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>
Subject: Re: [PATCH 06/15] batman-adv: Distributed ARP Table
 - add snooping functions for ARP messages
Date: Wed, 23 May 2012 23:48:02 +0200
Message-ID: <20120523214802.GA12222@pandem0nium>
References: <1335689867-8017-7-git-send-email-ordex@autistici.org>
	<20120430.205904.288157818941040253.davem@davemloft.net>
	<201205121626.38520.lindner_marek@yahoo.de>
	<201205171953.54891.lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201205171953.54891.lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello David,=20

we are a little bit in a pinch here - the DAT feature sent with this
patchset was developed for a long time, and we need your decision to move on
as more and more patches depend on it:

 * should we rewrite DAT to use our own ARP table/backend or
 * can we use the ARP neighbor table in another way, maybe after your chang=
es?

We thought that re-using existing infrastructure would be smarter, but if
you disagree, please tell us so - we would like to get this feature finally
upstream and need your input to make the neccesary changes.

Thanks
	Simon


On Thu, May 17, 2012 at 07:53:54PM +0800, Marek Lindner wrote:
>=20
> David,
>=20
> > On Tuesday, May 01, 2012 08:59:04 David Miller wrote:
> > > From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> > > Date: Tue, 1 May 2012 00:22:30 +0200
> > >=20
> > > > However this patch also contains a procedure which queries the neigh
> > > > table in order to understand whether a given host is known or not.
> > > > Would it be possible to do that in another way (Without manually
> > > > touching the table)?
> > > >=20
> > > > Instead, in the next patch (patch 06/15) batman-adv manually increa=
se
> > > > the neigh timeouts. Do you think we should avoid doing that as well?
> > > > If we are allowed to do that, how can we perform the same operation=
 in
> > > > a cleaner way?
> > > >=20
> > > > Last question: why can't other modules use exported functions? Are =
you
> > > > going to change them as well?
> > >=20
> > > I really don't have time to discuss your neigh issues right now as I'm
> > > busy speaking at conferences and dealing with the backlog of other
> > > patches.
> > >=20
> > > You'll need to find someone else to discuss it with you, sorry.
> >=20
> > I hope now is a good moment to bring the questions back onto the table.=
 We
> > still are not sure how to proceed because we have no clear picture of w=
hat
> > is going to come and how the exported functions are supposed to be used.
> >=20
> > David, if you don't have the time to discuss the ARP handling with us c=
ould
> > you name someone who knows your plans and the code equally well ? So fa=
r,
> > nobody has stepped up.
>=20
> let me add another piece of information: The distributed ARP table does n=
ot=20
> really depend on the kernel's ARP table. We can easily write our own back=
end=20
> to be totally independent of the kernel's ARP table. Initially, we though=
t it=20
> might be considered a smart move if the code made use of existing kernel=
=20
> infrastructure instead of writing our own storage / user space API / etc,=
=20
> hence duplicating what is already there. But if you feel this is the bett=
er=20
> way forward we certainly will make the necessary changes.
>=20
> Regards,
> Marek
>=20

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk+9WxIACgkQrzg/fFk7axb+zQCfQncmbfbL4WHBJpfB3EUZ9p56
yeIAoKRuR0Q3de8smjoM3C7ECQju1C8h
=Tzda
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--
