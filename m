From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 6 Nov 2013 19:55:17 +1100
Message-ID: <20131106195517.044921fa5141fa781f8c87a9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__6_Nov_2013_19_55_17_+1100_zGp4lZPEjr2T9.em"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__6_Nov_2013_19_55_17_+1100_zGp4lZPEjr2T9.em
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/netfilter/ipset/ip_set_hash_netnet.c between commit 1a869205c75c
("netfilter: ipset: The unnamed union initialization may lead to
compilation error") from the net-next tree and commit
"net/netfilter/ipset/ip_set_hash_netnet.c: fix build with older gcc" from
the akpm tree.

The latter is a subset of the former. so I just dropped the latter.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__6_Nov_2013_19_55_17_+1100_zGp4lZPEjr2T9.em
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSegP7AAoJEMDTa8Ir7ZwVjYUQAJQWDoNmcHTaa544TaUEh25e
ZKVJhCmjKRm4K1i45yTrbYEz7F4FUQUG9i5fyoxhfAkcZdpgtYgqrZVJkiTyQfUk
uL3eXSC1B+Dh26TMiDj9ORUd7No3+RBfk2Z6fHzxAFRfJ0WWHTbeqN0ipiWLUA7y
vE+pSR1YYupDAtP4pruePAIp3uo+wzrNo2RZrVAEg4Dw3uLOPjhZPi1ei0CkazUT
n7Txt+ltOFsu0g8kwf/oJ+2Nf6tF8dgROrdPoNzuGGYlDlpE8LvHbyHA3Udsbs78
mNhqul7qOhhkeqsp2kQTR1I9d5VoL5IQZkyPU3wdpiW7Wk4Si6aX8pm+LSdy5R+L
Mdt4s0+N4DuOAc969cKA4FTb7Eb0OQ4OBElMehwMFtU+nMxWSj0Rty7KZtniYVGj
a+zlklhgmhG1b24VBk+y2+wBoJhlwihAwcJVvVL/J1RO+ixGCYYkKAXv6c5L2A9R
eSCr55pI4Tpgehevgj9IPPDNbLsigI16Ee+mgSd74DqZUnXln7+H1Qv2XqNk72VI
aB79FP4O0B3H0+PnhaxumQgIsUpRR/zoq9OCfezQyC5t39OShuPHJS3xgAzA4UcH
vujyzdG+kNHT1Twbu9tf49AGrRx72VDkVW/L8+P3m7+T3IgwuaJ3lvLslGAPNmvO
9dM8faaZAgspc/SrR9Ta
=J9Un
-----END PGP SIGNATURE-----

--Signature=_Wed__6_Nov_2013_19_55_17_+1100_zGp4lZPEjr2T9.em--
