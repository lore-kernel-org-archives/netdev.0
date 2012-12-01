From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 6/7] batman-adv: Allow to use rntl_link
	for device creation/deletion
Date: Sat, 01 Dec 2012 14:16:38 +0100
Message-ID: <15221362.NFC3M7kpXE@sven-laptop.home.narfation.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <1353715332-4284-6-git-send-email-sven@narfation.org>
 <20121201131108.GL24115@ritirata.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4171032.o65fDLRZnF";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20121201131108.GL24115-E/2OGukznS5g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--nextPart4171032.o65fDLRZnF
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

Please don't remove netdev from this discussion without a reason.

On Saturday 01 December 2012 14:11:08 Antonio Quartulli wrote:
> On Sat, Nov 24, 2012 at 01:02:11AM +0100, Sven Eckelmann wrote:
> > The sysfs configuration interface of batman-adv to add/remove
> > soft-interfaces is not deadlock free and doesn't follow the currently
> > common way to create new virtual interfaces.
> > 
> > An additional interface though rtnl_link is introduced which provides easy
> > device creation/deletion with tools like "ip":
> > 
> > $ ip link add dev bat0 type batadv
> > $ ip link del dev bat0
> > 
> > Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> 
> Hello Sven,
> 
> why are we adding yet another API? What's the purpose? Is this intended to
> fix the lock bug we get while using sysfs?

Because this is the normal way to create virtual network devices (please feel 
free to correct me). And no, it doesn't fix the sysfs problem because the 
sysfs stuff isn't removed.

Kind regards,
	Sven
--nextPart4171032.o65fDLRZnF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQugM2AAoJEF2HCgfBJntG4wIP/i5jt5K820bPgXHlbt6+TPQK
mXVC3lwTaJXSNe4QGUV8E350RFjsiO+Is3L1+ci9UkPYYw0pSxGUOZptxRk+VwRB
6vXgwZ6v8aKbp9ZBF7/9TzNZMViGlzyXpyz4Z/SZJKlad4KzhJe3fuuUzlFfYAPH
IXQCbC0SCOKwvgHE2isD8GzLehIyDeMHLvEs32PciO2sZNEoMf/meATWO7LM73XJ
WZUcGKuMWD3j/rzZUMR7z7KREbOFHvVbC+NfRRW8+Zh+e7B+Utv8yEfvncdhrGbZ
pb/e+Y2SGtCs35Dzt2sd6bP3nibOG8+LKn26uIIE7QSEKPHqi6M97Du09cTvV8f8
sEM5s47OTDtHVmFiUSJrdRHey35deI1FRkYe2AfFmq70P/7nxbKxBJNMsLWNaHFM
jKQHGWE7dmkpPafXrtynXdF2eR5TP2hIRy5DmIK6/teJB5f/y3Hryz1mFFIXUpuB
ZBKeu3c9rXvMlYX+ylGQ6zVgSSwEkwFhOIkkpn56pT2zm9AUm7k8wToETEEeYkYt
HmFWNmnpLg9Z2XUZwaNwZ0WhPVujzjyyVCpp5QIg33k1mGue5JjXwp5/no7QeO1d
NmYPF1Wk09M6nhIli/3Vy0IzZEoxnUbmczuWSzi9KvH8BosDwezpj2XMQli7STFh
8vsmUWhY96T+t3ouEtU5
=uicR
-----END PGP SIGNATURE-----

--nextPart4171032.o65fDLRZnF--
