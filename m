From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC][PATCH] x86: remove vmalloc.h from asm/io.h
Date: Tue, 2 Jun 2015 10:19:22 +1000
Message-ID: <20150602101922.343a8012@canb.auug.org.au>
References: <20150529191847.2d4cb3a7@canb.auug.org.au>
 <20150601.155931.1230241015446814769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2414694306556479053=="
Cc: alsa-devel@alsa-project.org, x86@kernel.org, tiwai@suse.de,
 viresh.kumar@linaro.org, perex@perex.cz, kristen@linux.intel.com,
 hpa@zytor.com, buchino@cisco.com, tglx@linutronix.de,
 linux-scsi@vger.kernel.org, vinod.koul@intel.com, anton@enomsg.org,
 linux-acpi@vger.kernel.org, mingo@redhat.com, xen-devel@lists.xenproject.org,
 lenb@kernel.org, keescook@chromium.org, konrad.wilk@oracle.com,
 haiyangz@microsoft.com, JBottomley@odin.com, boris.ostrovsky@oracle.com,
 sramars@cisco.com, tony.luck@intel.com, netdev@vger.kernel.org,
 linux-pm@vger.kernel.org, hiralpat@cisco.com, rjw@rjwysocki.net,
 linux-kernel@vger.kernel.org, david.vrabel@citrix.com, ccross@android.com,
 dmaengine@vger.kernel.org, devel@linuxdriverproject.org,
 akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150601.155931.1230241015446814769.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

--===============2414694306556479053==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/zO9/aqai9vY0YrMljW=6zpt"; protocol="application/pgp-signature"

--Sig_/zO9/aqai9vY0YrMljW=6zpt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 01 Jun 2015 15:59:31 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 29 May 2015 19:18:47 +1000
>=20
> > Nothing in asm/io.h uses anything from vmalloc.h, so remove the include
> > and fix up the build problems in an allmodconfig (64 bit and 32 bit)
> > build.
> >=20
> > This may be the place where x86 builds get vmalloc.h implicitly included
> > and that tends to hide places where vmalloc() et al are added to files
> > but the include of vmalloc.h is forgotten.
> >=20
>  ...
> > Suggested-by: David Miller <davem@davemloft.net>
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> With the follow-on allnoconfig fixes:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

Noted, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/zO9/aqai9vY0YrMljW=6zpt
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVbPaPAAoJEMDTa8Ir7ZwVSRMP/RqSVOgIYLMd6jY+xHYuR1X+
CAI0Ar5tDaUWBbHiUFO+JP96M/Um9V3JRVqmflMT2lMQNnK67WSVMa4bFbMMXPnO
QRmcFeEuvn2JPsZxBIYEqOxpZFBJbEp7CGp0VCdue2qAP/pterC8b4aDxZgfPds2
wGWUkcOgyvX6++/TizmwiXw6OlQwjRWTUelMqNXoW3RqND8GdWyuLaiEKMMazJx1
xCU+Lnh9KW3q1yQVkokdt9FcW6ME5DgzdFiernajVzaJlakLQgvqruf+4UOzM3m+
3LkGuzfNcPon2JVMov7B4xmk03QPkQOUCdJoqw3NsrT8wZxEsuDndmCE3+/JXyTX
75eMtPoOA4Y810CWXkOZrKFPxBahQGze0GF3ZQO7SzhK9cF2bFDMzSWi2vJmT/22
qZlwPn4Z2spEwKS96Bn39JCavZroPA5R5YiuP5tWFG24ttjQgy4NNhAoKOOffiEE
2lVrKssJDnesvBR/aV/kwqG8FLBniQYPusNEUr7QbCWLtFEQ7ucWqUrxeYySHzEX
4Fxbxp73JxiE7P9qc55JQ+O7SyLHfvPNPFMG3w8f7HqSmffONNHQd5cP5bhWmWRb
671Q31r4nz9V/NagsEzCFNdB7LnH24z3cfUjcTzKkihti1TKbTBoYECsAk9lZ+ZY
VmDJ5yHOYG8uW0q3A0lt
=pplq
-----END PGP SIGNATURE-----

--Sig_/zO9/aqai9vY0YrMljW=6zpt--

--===============2414694306556479053==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============2414694306556479053==--
