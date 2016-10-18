From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 2/9] ipv6: sr: add code base for control plane support
 of SR-IPv6
Date: Tue, 18 Oct 2016 13:45:53 +0200
Message-ID: <58060B71.40900@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be> <1476715350-18983-3-git-send-email-david.lebrun@uclouvain.be> <CALx6S34XW0DUBYJBHdCuegSLeDvS9d_e71xEduxVZfohGprrHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="Fa2RfaoDKwdHKBwUbsHp6o4SFJkv0b08t"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39339 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbcJRLoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 07:44:22 -0400
In-Reply-To: <CALx6S34XW0DUBYJBHdCuegSLeDvS9d_e71xEduxVZfohGprrHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Fa2RfaoDKwdHKBwUbsHp6o4SFJkv0b08t
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 07:07 PM, Tom Herbert wrote:
>> +static inline void seg6_pernet_lock(struct net *net)
>> +{
>> +       mutex_lock(&seg6_pernet(net)->lock);
>> +}
>> +
>> +static inline void seg6_pernet_unlock(struct net *net)
>> +{
>> +       mutex_unlock(&seg6_pernet(net)->lock);
>> +}
>> +
> IMO it's better not to hide mutex_lock/unlock in a static inline
> function. Pairing mutex_lock with mutex_lock is critical and should be
> each to see in code.
>=20

OK

>> +
>> +static int seg6_genl_sethmac(struct sk_buff *skb, struct genl_info *i=
nfo)
>> +{
>> +       return -ENOTSUPP;
>=20
> Is the intent to implement this later?
>=20

The implementation is in this patch series with the rest of the HMAC code=



--Fa2RfaoDKwdHKBwUbsHp6o4SFJkv0b08t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgGC3QACgkQjbzn67sZ6AOhbwCeIka2JZG9KQzpARA4PNaG47FX
fAUAnjGWWbiTRkE+pCfmvGtOB2YEltzu
=ZnFb
-----END PGP SIGNATURE-----

--Fa2RfaoDKwdHKBwUbsHp6o4SFJkv0b08t--
