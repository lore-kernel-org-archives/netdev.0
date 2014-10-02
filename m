From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
	TCQ_F_ONETXQUEUE
Date: Thu, 02 Oct 2014 12:08:16 +0200
Message-ID: <87fvf6wzqn.fsf@toke.dk>
References: <20140930085114.24043.81310.stgit@dragon>
	<542A8EF9.10403@mojatatu.com>
	<20140930.142038.235338672810639160.davem@davemloft.net>
	<542BFEF3.7020302@mojatatu.com>
	<CA+mtBx8rVu9FXtnc18n22L9LP=t=3Pso7U2yvvLcnny57w8aXg@mail.gmail.com>
	<542C1F1F.90404@mojatatu.com> <20141001192840.5679a671@redhat.com>
	<542C4E0D.4050404@mojatatu.com> <20141001214700.18b16387@redhat.com>
	<542C5E8B.7070204@mojatatu.com> <20141001223229.6cbaac07@redhat.com>
	<CAA93jw5orK2FeD20zcFpXGkqGa=kF8E-vGtkdUs7vr54R5AE6g@mail.gmail.com>
	<20141002094418.37f6ecb4@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: Dave Taht <dave.taht@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([77.235.48.147]:36437 "EHLO mail2.tohojo.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbaJBKPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:15:42 -0400
In-Reply-To: <20141002094418.37f6ecb4@redhat.com> (Jesper Dangaard Brouer's
	message of "Thu, 2 Oct 2014 09:44:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Jesper Dangaard Brouer <brouer@redhat.com> writes:

> Perhaps Toke have an opinion on the output formatting from bqlmon?

Anything that outputs one record per line and is parsable by regular
expression is fine with me. I don't currently have a runner that
captures json output, so doing that would actually be more work for me
to support presently :)

-Toke

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJULSQQAAoJEENeEGz1+utPYegIAJXQuhi7PoLMz8X9+TtdTL+O
XN4ObhJWxmIRuKm6NOHHeWu1yJM4Y0yo0SqgHuEtC7IhPLhyE7fxKB+BhSIc1H90
wmy366CdLW5Sy2joKtH9T6uazpF7IJ7tEZ7q3uS1OHfnnVtSTfRF5npZPgydFF/e
1SDMXnDMZ3hiqrW6GkObOErE7+2oKfM53zUTY59RdkYHpBQ+SiNVoYUV0WAWH3A0
ERsUR9kCMuJv7hRkONfqqk+2O7s3pZxu+Adu4U6QEoVXozzv424EUEGRdDU2l8RU
MbldRm817vPN73YW4aIUXtWwfGM+HnZ3QGj4yWhUdma7bQ52M0Scg2vD2q8ydAA=
=MuI2
-----END PGP SIGNATURE-----
--=-=-=--
