From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Mon, 24 Nov 2014 01:06:12 +0000
Message-ID: <1416791172.7215.68.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043352.GH30478@ZenIV.linux.org.uk>
	 <1416788862.7215.65.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8ijQbJOlxHcm4zrxawa/"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416788862.7215.65.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8ijQbJOlxHcm4zrxawa/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-24 at 00:27 +0000, Ben Hutchings wrote:
> On Sat, 2014-11-22 at 04:33 +0000, Al Viro wrote:
[...]
> Does skb_copy_datagram_from_iter() really need a len parameter?  Here it
> is equal to iov_iter_count(from).
[...]
> Again len is equal to iov_iter_count(from), so I think that parameter is
> redundant.

Having read further patches, I see that unix_stream_sendmsg() is the one
exception where the length parameter is different.  But maybe the common
case (len =3D iter_iov_count(iov)) deserves a wrapper function?

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-8ijQbJOlxHcm4zrxawa/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHKEiee/yOyVhhEJAQrEAxAAomC2D+xQAWyKPQ1OIYArzl0jZHojasQv
+8QMrZCHbjmVlzRkG/4dO7RNY8iB9L0VyjsEDXfI45KGT+++teht8hcV26UumJ9s
n6bUwQSHZuXscKJDkvvKzN1ck5vSpXLWB01z1qtbiOS2cacR6Yy1VYUCfYt1pCe6
YPOF7bdi7ZZ/10uyPfv25eIICxgXBqKa2xzlu8bndYv4Bul229vJzPV7GrbyBxQh
Leu8p2ysZyyRcizfarfHDkhM41wTUFMa41G3u8NT/9RQOaKS6mr+sDp31Sf5SQU3
A8DgVnrwrYk8O7z/9CGE/Ba/iJ+0Mjl5JcLZs18aeUQi5kxWH3TR8ZpHmezwTs3J
q2dUIXrVTWNgmeQeHrd0CSVECFy/fWvS4onn+NRIy8wXkMHXbgiydbvN2V2qjazN
5YTHcUxq0WMS6m1C+PhE1VS0iU9DCaYIe6fiVYhUmPX5nPE+0HJMIewHSkOls+CP
kXI33rzAV64I0DgdQjqFhfpX+K6QeC4RQtT3exl/9qYFlUz2nNwdsmbqE1oE1ddT
9TKgMS2VsAOQFP6xzmG5kRkzNa5owpdWdGc3UbXVe8wy2A75m3xcBbW2OH9gLGyH
ocdGZacZBIhvEca0+fh2LSdk0iMg38iieagm5eNvgtcLUIuoiveJzj1GmurmnYpm
aKfGD7SJdXA=
=P/WF
-----END PGP SIGNATURE-----

--=-8ijQbJOlxHcm4zrxawa/--
