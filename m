From: Valdis.Kletnieks@vt.edu
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Tue, 24 May 2011 20:34:53 -0400
Message-ID: <4508.1306283693@localhost>
References: <m11uzrvd26.fsf@fess.ebiederm.org> <BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com> <m1boyvpo9r.fsf@fess.ebiederm.org> <1306048393.4092.8.camel@mulgrave.site> <20110522084224.GA12279@elte.hu> <m1k4dgr35i.fsf@fess.ebiederm.org>
            <20110524071628.GA31612@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1306283693_2629P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 24 May 2011 09:16:28 +0200."
             <20110524071628.GA31612@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1306283693_2629P
Content-Type: text/plain; charset=us-ascii

On Tue, 24 May 2011 09:16:28 +0200, Ingo Molnar said:
> * Eric W. Biederman <ebiederm@xmission.com> wrote:
> > My gut feel says we should really implement an
> > include/asm-generic/unistd-common.h to include all new system calls.
> >
> > That way there would be only one file to touch instead of 50. Certainly it
> > works for include/asm-generic/unistd.h for the architectures that use it. 
> > And all we really need is just a little abstraction on that concept.
>
> I suppose that could be tried, although in practice it would probably be
> somewhat complex due to the various compat syscall handling differences.

Can somebody fill us newcomers in on the arch-aeology of why some syscalls have
different numbers on different archs? I know it's partially because some simply
didn't implement some syscalls so there were numbering mismatches, but would it
have been *that* hard to wire all of those skipped syscalls up to one stub
'return -ENOSYS'?


--==_Exmh_1306283693_2629P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFN3E6tcC3lWbTT17ARAoUzAKDkLdqvlB6vCeoSImcc2cdgyprBtgCeLf6P
rJQ+3GeD0kVUaVPYr2AFv2w=
=8lZN
-----END PGP SIGNATURE-----

--==_Exmh_1306283693_2629P--
