From: Andre Noll <maan@tuebingen.mpg.de>
Subject: Re: [PATCH net] flow_dissect: call init_default_flow_dissectors()
 earlier
Date: Tue, 22 Nov 2016 20:44:14 +0100
Message-ID: <20161122194414.GG19939@tuebingen.mpg.de>
References: <20161122170654.GA20022@kroah.com>
 <CANn89iJCkHxOpE3TW8+gW8+UCVvT0mY8y8j_GJC1GK0i05dgbg@mail.gmail.com>
 <1479836511.681.165.camel@intel.com>
 <CANn89iLdtfoYDVoszduyKCpmZpYcpV2=UnwbjAzH0G08nzNwbw@mail.gmail.com>
 <20161122175504.GD19939@tuebingen.mpg.de>
 <CANn89iKZMcnzLJUNE286pBKSaL3kcrBgwpdihxSMm8Ze5L_-qw@mail.gmail.com>
 <20161122180605.GE19939@tuebingen.mpg.de>
 <1479838123.681.173.camel@intel.com>
 <20161122182258.GF19939@tuebingen.mpg.de>
 <1479842250.8455.452.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="rV8arf8D5Dod9UkK"
Cc: Jiri Pirko <jiri@resnulli.us>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ast@kernel.org" <ast@kernel.org>,
        "willemb@google.com" <willemb@google.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "jslaby@suse.cz" <jslaby@suse.cz>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "yibyang@cisco.com" <yibyang@cisco.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479842250.8455.452.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rV8arf8D5Dod9UkK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 22, 11:17, Eric Dumazet wrote
> -late_initcall_sync(init_default_flow_dissectors);
> +core_initcall(init_default_flow_dissectors);

Indeed, that fixed it. Feel free to add

Tested-by: Andre Noll <maan@tuebingen.mpg.de>

Thanks a lot
Andre
--=20
Max Planck Institute for Developmental Biology
Spemannstra=C3=9Fe 35, 72076 T=C3=BCbingen, Germany. Phone: (+49) 7071 601 =
829
http://people.tuebingen.mpg.de/maan/

--rV8arf8D5Dod9UkK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg0oA4ACgkQWto1QDEAkw8OQwCglArGZmEi/ogIBJT7Zxa7fJjT
isEAoItLfij/XEUJcUanQ2tYgU1wWlz0
=jShp
-----END PGP SIGNATURE-----

--rV8arf8D5Dod9UkK--
