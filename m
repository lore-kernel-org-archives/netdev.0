From: Valdis.Kletnieks@vt.edu
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 16:07:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405122007.i4CK7GPQ020444@turing-police.cc.vt.edu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>
            <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-846568836P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jgarzik@pobox.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Davide Libenzi <davidel@xmailserver.org>
In-Reply-To: Your message of "Wed, 12 May 2004 12:56:04 PDT."
             <Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-846568836P
Content-Type: text/plain; charset=us-ascii

On Wed, 12 May 2004 12:56:04 PDT, Davide Libenzi said:

> > If the kernel jiffie is anything other than exactly 1 msec, you're screwed.
.. 
> 
> I believe they were talking about include/asm-i386/param.h
>                                           ^^^^^^^^

True.

The problem is that even for the i386 family, there's no inherent reason why
the value of HZ is nailed to 1000 - it was changed from the default 100 in the
2.4 kernel for reasons that apply to most, but not all, machines, and there's
almost certainly people who are changing it back to 100 for good and valid
reasons.

We're still seeing the occasional code that goes gonzo because it assumed that
the default value of HZ was 100 (there's been more than a few bugs concerning
HZ/USER_HZ) - it would be foolish to go back and re-hard-code the value and
start the cycle all over again....


--==_Exmh_-846568836P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFAooP0cC3lWbTT17ARAn69AKCaN2cKcQLKOYh+/H6P2sH+HSsbtwCg5RjC
cDKLLHf1nBvnDSW16FoqfKk=
=u1/v
-----END PGP SIGNATURE-----

--==_Exmh_-846568836P--
