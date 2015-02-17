From: Matthew Thode <mthode@mthode.org>
Subject: Re: [PATCH] colons are invalid characters in netdev names
Date: Tue, 17 Feb 2015 17:57:15 -0600
Message-ID: <54E3D55B.6030304@mthode.org>
References: <1424214942-17581-1-git-send-email-mthode@mthode.org> <54E3D2BE.30305@gmx.de>
Reply-To: mthode@mthode.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="FHmuwE9kKdINBBoMXQxnwMoLU5kunUc9j"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E3D2BE.30305@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FHmuwE9kKdINBBoMXQxnwMoLU5kunUc9j
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/17/2015 05:46 PM, Lino Sanfilippo wrote:
> On 18.02.2015 00:15, Matthew Thode wrote:
>> colons are used as a separator in netdev device lookup in dev_ioctl.c
>>
>> Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME
>>
>> Signed-off-by: Matthew Thode <mthode@mthode.org>
>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index d030575..e9b6d5a 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -942,7 +942,7 @@ bool dev_valid_name(const char *name)
>>  		return false;
>>  	if (strlen(name) >=3D IFNAMSIZ)
>>  		return false;
>> -	if (!strcmp(name, ".") || !strcmp(name, ".."))
>> +	if (!strcmp(name, ".") || !strcmp(name, "..") || !strcmp(name, ":"))=

>>  		return false;
>> =20
>>  	while (*name) {
>>
>=20
> Hi,
>=20
> that check should be done in the loop below, shouldn't it?
>=20
> Regards,
> Lino
>=20
You are correct,  should I resend a patch.  Not really sure the
procedure of updating a patchset sent to the ML.

--=20
Matthew Thode


--FHmuwE9kKdINBBoMXQxnwMoLU5kunUc9j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJU49VbAAoJEGSje+quGaToCzoQAIcKcV/Oxtpnk3VbC0KiwQwd
K7lWw4Gua0KCjDdYQGigCCk2yBAswnGBgcvsLI+w1GGr/xx0sRywNKrF2fiHKmod
V1LwhTskhunQa5Cj3Auc9liiLcKLfMoPXkTNh081jN4lpfSz2d2hDp+2lsiMNzux
Nzf9G+5xDnMfzYEW3Xal5ucVH018ZyN8AZXOEGMKCjMBP7eK49bhO0W71DRooX48
Iq+xcJqlJDOM7dsrh9sGdK55SMThtI6d/yWMU834IzQuEDYwd6bOqn+bJZaJzmUK
3AQS+kEM3uPLC5AXKYLX2WnVfkdoj14zw4OiO/pyGcef4NFZu3u5CWXXhj4K5xRU
9vbNdp9io1xyq2PcqC22G9BEXGGhS+TPrKNCPVWbi21niDzgUAN7manKIxMZUGy/
ikyK4iRjJh2A2Sud2G3BgCN7Nng59AdUjYbo8gmEoHlcyaPPdyRHMqg2td/yk3WZ
jV16l9koi6Uek85r2jPt2CB6JusVW+1n6uCTTaNSUxAZQZFZ1idXh/92s4Y1oFjk
SnKGpx1btu7LjkSm7RM+iGFgiftvItrZLSvrNj0Mk2tTzHbyCe3ZanESHQI59lQ9
RpMlys4X6xZWeRn+SvGXS3Ba53oxbqNhXxlX+s3ayhZDQrQYTQhJcPB47a8I6zI4
ncga0ePFE5LicqZ90y+y
=BM5k
-----END PGP SIGNATURE-----

--FHmuwE9kKdINBBoMXQxnwMoLU5kunUc9j--
