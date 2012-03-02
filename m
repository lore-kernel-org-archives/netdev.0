From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 2 Mar 2012 14:57:50 +1100
Message-ID: <20120302145750.41b96e8be011a9a73c4fedf7@canb.auug.org.au>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<20120301233712.GS3990@outflux.net>
	<20120302114705.0a9542e138927897f16282ca@canb.auug.org.au>
	<CAGXu5jL0OXR5MOePFe=GT4_X5rdH8RNjQPqYXdbqsqfijUsEqA@mail.gmail.com>
	<20120302141038.aaafc42b59ac7cf95d3553ed@canb.auug.org.au>
	<CABmXcB83uFMUFUuRKCtkMjU2KLv7N4JB08qzZLVDdT=CStmQjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__2_Mar_2012_14_57_50_+1100_eKb16QfO7sCCyQX9"
Cc: Kees Cook <keescook@chromium.org>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABmXcB83uFMUFUuRKCtkMjU2KLv7N4JB08qzZLVDdT=CStmQjw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__2_Mar_2012_14_57_50_+1100_eKb16QfO7sCCyQX9
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 1 Mar 2012 21:41:51 -0600 Will Drewry <wad@chromium.org> wrote:
>
> No explicit dependency.   It's just a conflict in how ptrace options
> are set, defined, and masked (and STOP being renumbered).  Other than
> the ptrace changes, the whole series patches cleanly onto both trees.
> The resolved version is less code and easier to read, so I don't
> suspect it'll be a challenge at all.

OK, so we need a tree based on Linus' (like v3.3-rc5 or something - and
preferably tested ;-)) and an explicit request to me to include that tree.

I will sort out any conflicts with Andrews's tree and post the fixups I
make so others can correct me if necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__2_Mar_2012_14_57_50_+1100_eKb16QfO7sCCyQX9
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPUEU+AAoJEECxmPOUX5FEpwAP/REQHzmhoCTZS02bUk+qc0AP
V99l9dTuhNEgQsDW23aMXy26Q6yUkoNJcsaOzcp8zxTcxLySKy8I9KYCld52fjcm
JFdPpYR/cHUsSb0tbfDwnFEXDGHUh1OqGWp1GmS/6WoZWLd0mWioVm6FBgiDVr0k
aj9SZmjeHzyEZco/XLaty3eA+5jRHfFLC0n9d1g2C57P8LrPzns7MfHQdXclgulm
P4/E1AEewbx7nYwDdtzcupSWOSDPanppgqT7942uty1qSmMI/8QuqDiZFiDSGFU3
EYzbso5Y5N2FI01ic/z0HL25jiVoO19GIS1IYRr5M0DslNxtdxTpnkXVVdcPdTXm
IymIIN6fjQ1X7uAWRoS4ES9oHDbgUaHwkiM1KoJPCtF4k/tp7gH1W34GpCIolapt
4hr9NiPs5MED30n/q2M6hwWFnnX6DrdgfAzgFLyHnwkoeDvJ/47Ygpf3kKE+99hk
9JRORvSDI4pMKAig8CZmS8WOXgaRkOYrTTuJ6+fJWjBS/HMFWgY6ZwYJxX+VzRjW
939edFtsuy+lwk1V5hUrO4PSv2KrdFBgr5fRbmEib80FMOouCRzp4oc9SOB9Cz28
RTevmY88HpiqSFALRBaf5V9BkLbPvh1F6nfL26ASjJUjzRxWcUTBnNWBC2eqOYS4
1avPUU5cukzYPgzs3KWK
=g1Ug
-----END PGP SIGNATURE-----

--Signature=_Fri__2_Mar_2012_14_57_50_+1100_eKb16QfO7sCCyQX9--
