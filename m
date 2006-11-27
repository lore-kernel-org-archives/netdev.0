From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] [UDP(-Lite)]: consolidate v4 and v6 get|setsockopt code
Date: Mon, 27 Nov 2006 18:12:22 +0000
Message-ID: <200611271812.23073@strip-the-willow>
References: <200611271044.34091@strip-the-willow> <20061127.093134.45504470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:12265 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1757852AbWK0SMA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 13:12:00 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061127.093134.45504470.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller:
|  > =A0=A0=A0=A0=A0=A0if (level =3D=3D SOL_UDP =A0|| =A0level =3D=3D S=
OL_UDPLITE)
|  > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return do_udpv6_setsockopt=
(sk, level, optname, optval, optlen);
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return udp_lib_setsockopt(=
sk, level, optname, optval, optlen,
|  > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0udp_v6_push_pending_fr=
ames =A0 =A0 =A0 =A0 );
|  > =A0=A0=A0=A0=A0=A0return compat_ipv6_setsockopt(sk, level, optname=
, optval, optlen);
|  > =A0}
|  > =A0#endif
| =20
|  Specifically, the space between the push_pending_frames final argume=
nt
|  passed and the closing parenthesis was removed. =A0Why did you put
|  that there? =A0It looks fugly :)
Thank you for ironing this out, and a nice euphemism, too |-) The inten=
tion was to match
the end of the arguments list in the preceding line. But it seems that =
my feeble attempts
to be neat here have not met with wide approval ..... still enjoying th=
e euphemism :-)

Many thanks and best regards
Gerrit
