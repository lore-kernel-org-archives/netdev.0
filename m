From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re: A common layer for Accounting packages
Date: Mon, 28 Feb 2005 08:17:31 +0300
Message-ID: <1109567851.28266.5.camel@uganda>
References: <42168D9E.1010900@sgi.com>
	 <20050218171610.757ba9c9.akpm@osdl.org> <421993A2.4020308@ak.jp.nec.com>
	 <421B955A.9060000@sgi.com> <421C2B99.2040600@ak.jp.nec.com>
	 <421CEC38.7010008@sgi.com> <421EB299.4010906@ak.jp.nec.com>
	 <20050224212839.7953167c.akpm@osdl.org> <20050227094949.GA22439@logos.cnet>
	 <4221E548.4000008@ak.jp.nec.com> <20050227140355.GA23055@logos.cnet>
	 <42227AEA.6050002@ak.jp.nec.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pCaTatLiGl3pT+YdyW8k"
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	Andrew Morton <akpm@osdl.org>, davem@redhat.com, jlan@sgi.com,
	lse-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
To: Kaigai Kohei <kaigai@ak.jp.nec.com>
In-Reply-To: <42227AEA.6050002@ak.jp.nec.com>
Sender: lse-tech-admin@lists.sourceforge.net
Errors-To: lse-tech-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:lse-tech@lists.sourceforge.net>
List-Help: <mailto:lse-tech-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=lse-tech>
List-Id: netdev.vger.kernel.org


--=-pCaTatLiGl3pT+YdyW8k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2005-02-28 at 10:59 +0900, Kaigai Kohei wrote:
> Hello,
>=20
> Marcelo Tosatti wrote:
>  > Yep, the netlink people should be able to help - they known what would=
 be
>  > required for not sending messages in case there is no listener registe=
red.
>  >
>  > Maybe its already possible? I have never used netlink myself.
>=20
> If we notify the fork/exec/exit-events to user-space directly as you said=
,
> I don't think some hackings on netlink is necessary.
> For example, such packets is sent only when /proc/sys/.../process_groupin=
g is set,
> and user-side daemon set this value, and unset when daemon will exit.
> It's not necessary to take too seriously.


Kernel accounting already was discussed in lkml week ago - I'm quite=20
sure Guillaume Thouvenin created exactly that.
His module creates do_fork() hook and broadcasts various process' states
over netlink.

Discussion at http://lkml.org/lkml/2005/2/17/87

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-pCaTatLiGl3pT+YdyW8k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCIqlrIKTPhE+8wY0RAthtAJ0RD3Cp+M7g8KRNKmsk3aDKkssYwgCfaXXF
hDb9HN70L6Uio6XFUIDg+3Y=
=ZWTO
-----END PGP SIGNATURE-----

--=-pCaTatLiGl3pT+YdyW8k--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
