From: Ludo Stellingwerff <ludo@protactive.nl>
Subject: Re: [22/*] [NETFILTER] Use correct IPsec MTU in TCPMSS
Date: Sun, 20 Mar 2005 19:11:26 +0100
Message-ID: <423DBCCE.8090006@protactive.nl>
References: <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318104013.57d65e99.davem@davemloft.net> <423D9ADA.6050407@trash.net> <423DA58D.4050406@protactive.nl> <20050320171707.GE4201@xi.wantstofly.org> <423DB7B7.1070604@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <423DB7B7.1070604@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


Patrick McHardy wrote:

| Lennert Buytenhek wrote:

|> - I have no idea beforehand what the remote nexthop is going to
|> be.  A1 might ordinarily send its traffic for site B to B1, but
|> if B1 fails it'll want to start using B2 instead, which would be
|> prevented by the SPD rule hardcoding the remote tunnel endpoint
|> to B1.
|>
|
| Hmm .. sounds like using the routing realm in the selector would
| solve this while avoiding the GRE overhead.
|
| Regards Patrick
|
I'm hoping that using the fwmark as a selector can provide a workable
solution for both mine and Lennert's problem, any many more related
situations. Netfilter has a (almost) complete range of selectors.
e.g. Lennerts problem could be solved using a combination of the
"realm" match of iptables, in combination with a fwmark for SPD matching.

Greetings,
Ludo.

PS. On a side note: Wouldn't it be possible to have a netfilter target
stating that an transformation should be done?

- --
Ludo Stellingwerff

V&S B.V. The Netherlands
ProTactive firewall solution.
Tel: +31 172 416116
Fax: +31 172 416124

site: www.protactive.nl
demo: http://www.protactive.nl:81/netview.html
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCPbzNOF3sCpZ+AJgRApxBAJ9akLfP1onp+WKRgmJ1YDImkrXLHwCgkPS4
GvwO1PoUwkJnVTOjeaf/ZEw=
=OebA
-----END PGP SIGNATURE-----
