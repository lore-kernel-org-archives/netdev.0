From: Valdis.Kletnieks@vt.edu
Subject: Re: PATCH: kmalloc packet slab
Date: Mon, 27 Dec 2004 17:50:01 -0500
Message-ID: <200412272250.iBRMo2Qb011114@turing-police.cc.vt.edu>
References: <1104156983.20944.25.camel@localhost.localdomain> <41D043AC.2070203@trash.net>
            <20041227142350.1cf444fe.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1419475951P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, alan@lxorguk.ukuu.org.uk,
        torvalds@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: Your message of "Mon, 27 Dec 2004 14:23:50 PST."
             <20041227142350.1cf444fe.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-1419475951P
Content-Type: text/plain; charset=us-ascii

On Mon, 27 Dec 2004 14:23:50 PST, "David S. Miller" said:

> If we are really going to do something like this, it should
> be calculated properly and be determined per-interface
> type as netdevs are registered.

Would you prefer to see this done for all interface types if we do it
at all, or would a special-case for 1 or 2 types that can use a slab
without being wasteful be an acceptable solution? (Let's face it - if
3.95 objects fit in each slab, we may not want to do it...)

--==_Exmh_-1419475951P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFB0JGZcC3lWbTT17ARAtkPAKDjhu4Ocy8aQbbY8GwpjCG9aaTu+wCgybsg
s31h8DjurnRR1B6j4DuSr7Y=
=3OVm
-----END PGP SIGNATURE-----

--==_Exmh_-1419475951P--
