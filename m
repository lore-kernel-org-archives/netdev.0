From: David Hollis <dhollis@davehollis.com>
Subject: [PATCH] tg3.h & b44.h ifndef ADVERTISE_PAUSE typo
Date: Tue, 11 Jan 2005 09:42:33 -0500
Message-ID: <1105454553.4264.4.camel@dhollis-lnx.centricconsulting.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-o4RiUs3lCqkUr5oeoFjS"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-o4RiUs3lCqkUr5oeoFjS
Content-Type: multipart/mixed; boundary="=-PkaztbHcB1OMnKtuQu/D"


--=-PkaztbHcB1OMnKtuQu/D
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

tg3.h and b44.h define ADVERTISE_PAUSE_CAP if ADVERTISE_PAUSE
is not defined.  Both include a notation that these values should
be added to mii.h.  If ADVERTISE_PAUSE_CAP was added to mii.h,
these defines would break since they are checking for ADVERTISE_PAUSE
instead of ADVERTISE_PAUSE_CAP.

--=20
David Hollis <dhollis@davehollis.com>

--=-PkaztbHcB1OMnKtuQu/D
Content-Disposition: attachment; filename=b44_tg3_advertise_define.patch
Content-Type: text/x-patch; name=b44_tg3_advertise_define.patch; charset=UTF-8
Content-Transfer-Encoding: base64

dGczLmggYW5kIGI0NC5oIGRlZmluZSBBRFZFUlRJU0VfUEFVU0VfQ0FQIGlmIEFEVkVSVElTRV9Q
QVVTRQ0KaXMgbm90IGRlZmluZWQuICBCb3RoIGluY2x1ZGUgYSBub3RhdGlvbiB0aGF0IHRoZXNl
IHZhbHVlcyBzaG91bGQNCmJlIGFkZGVkIHRvIG1paS5oLiAgSWYgQURWRVJUSVNFX1BBVVNFX0NB
UCB3YXMgYWRkZWQgdG8gbWlpLmgsDQp0aGVzZSBkZWZpbmVzIHdvdWxkIGJyZWFrIHNpbmNlIHRo
ZXkgYXJlIGNoZWNraW5nIGZvciBBRFZFUlRJU0VfUEFVU0UNCmluc3RlYWQgb2YgQURWRVJUSVNF
X1BBVVNFX0NBUC4NCg0KU2lnbmVkLW9mZi1ieTogRGF2aWQgSG9sbGlzIDxkaG9sbGlzQGRhdmVo
b2xsaXMuY29tPg0KDQogZHJpdmVycy9uZXQvYjQ0LmggfCAgICAyICstDQogZHJpdmVycy9uZXQv
dGczLmggfCAgICAyICstDQogMiBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDIgZGVs
ZXRpb25zKC0pDQoNCi0tLSBhL2RyaXZlcnMvbmV0L2I0NC5oCTIwMDUtMDEtMTEgMDk6MzQ6Mzku
MTc4NzM5NzI4IC0wNTAwDQorKysgYi9kcml2ZXJzL25ldC9iNDQuaAkyMDA1LTAxLTExIDA5OjM0
OjU0LjIxNTQ1MzgwMCAtMDUwMA0KQEAgLTMwMyw3ICszMDMsNyBAQA0KICNkZWZpbmUgIE1JSV9U
TEVEQ1RSTF9FTkFCTEUJMHgwMDQwDQogDQogLyogWFhYIEFkZCB0aGlzIHRvIG1paS5oICovDQot
I2lmbmRlZiBBRFZFUlRJU0VfUEFVU0UNCisjaWZuZGVmIEFEVkVSVElTRV9QQVVTRV9DQVANCiAj
ZGVmaW5lIEFEVkVSVElTRV9QQVVTRV9DQVAJCTB4MDQwMA0KICNlbmRpZg0KICNpZm5kZWYgQURW
RVJUSVNFX1BBVVNFX0FTWU0NCi0tLSBhL2RyaXZlcnMvbmV0L3RnMy5oCTIwMDUtMDEtMTEgMDk6
MzQ6NDMuNTYyMDczMzYwIC0wNTAwDQorKysgYi9kcml2ZXJzL25ldC90ZzMuaAkyMDA1LTAxLTEx
IDA5OjM1OjAwLjc4NjQ1NDg1NiAtMDUwMA0KQEAgLTE1MzIsNyArMTUzMiw3IEBADQogI2RlZmlu
ZSBNSUlfVEczX0lOVF9BTkVHX1BBR0VfUlgJMHgwNDAwDQogDQogLyogWFhYIEFkZCB0aGlzIHRv
IG1paS5oICovDQotI2lmbmRlZiBBRFZFUlRJU0VfUEFVU0UNCisjaWZuZGVmIEFEVkVSVElTRV9Q
QVVTRV9DQVANCiAjZGVmaW5lIEFEVkVSVElTRV9QQVVTRV9DQVAJCTB4MDQwMA0KICNlbmRpZg0K
ICNpZm5kZWYgQURWRVJUSVNFX1BBVVNFX0FTWU0NCg==


--=-PkaztbHcB1OMnKtuQu/D--

--=-o4RiUs3lCqkUr5oeoFjS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB4+XYxasLqOyGHncRAp0jAJwKAqDdD6FwkI6RYY4xrzHVy1uV7wCfT3Xs
isuZI5Zj6U+5ljhqqPb/RB8=
=y/OI
-----END PGP SIGNATURE-----

--=-o4RiUs3lCqkUr5oeoFjS--
