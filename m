From: Valdis.Kletnieks@vt.edu
Subject: Re: [next] unix stream crashes
Date: Sun, 04 Sep 2011 10:43:35 -0400
Message-ID: <4762.1315147415@turing-police.cc.vt.edu>
References: <4E5FEF28.60406@gmail.com> <3179.1314924559@turing-police.cc.vt.edu> <1314927645.2576.2939.camel@schen9-DESK> <6805.1314979936@turing-police.cc.vt.edu> <1315007703.2576.2965.camel@schen9-DESK> <6043.1315028115@turing-police.cc.vt.edu> <CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com> <4E61C7F2.3090902@gmail.com>
            <CAAM7YAkB3VVNMmBMVuvEZuV6oGZeyog37_sjFGUunu+15apvZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1315147415_4592P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, sedat.dilek@gmail.com,
	Sedat Dilek <sedat.dilek@googlemail.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "Yan, Zheng " <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:52270 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961Ab1IDOpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2011 10:45:42 -0400
In-Reply-To: Your message of "Sat, 03 Sep 2011 20:30:19 +0800."
             <CAAM7YAkB3VVNMmBMVuvEZuV6oGZeyog37_sjFGUunu+15apvZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1315147415_4592P
Content-Type: text/plain; charset=us-ascii

On Sat, 03 Sep 2011 20:30:19 +0800, "Yan, Zheng " said:
> The skb can be destructed before the while loop in unix_stream_sendmsg stops.
> please try below patch.

Tried this on top of next-20110831, and system is up and running fine.

Feel free to stick this on it:

Tested-By: Valdis Kletnieks <valdis.kletnieks@vt.edu>

--==_Exmh_1315147415_4592P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOY46XcC3lWbTT17ARAs4bAKDnn1fa05GCMeIQpig/ctNZCoVbRgCgso4R
sxEdXl1bNQL5ZWInxdZDo5M=
=uZT1
-----END PGP SIGNATURE-----

--==_Exmh_1315147415_4592P--
