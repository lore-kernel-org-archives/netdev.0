From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: [PATCH, second try] Typo in comments in include/linux/igmp.h
Date: Mon, 3 Jan 2011 08:03:36 -0800 (PST)
Message-ID: <542376.97776.qm@web62505.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-797806555-1294070616=:97776"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web62505.mail.re1.yahoo.com ([69.147.75.97]:44352 "HELO
	web62505.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932069Ab1ACQDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 11:03:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0-797806555-1294070616=:97776
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

[Second try, patch invalid, sorry]=0A=0AHello,=0A=0AThere is a typo in comm=
ents in include/linux/igmp.h:=0A=0A83 #define IGMP_HOST_MEMBERSHIP_QUERY=A0=
 =A0 =A0 0x11=A0 =A0 /* From RFC1112 */=0A84 #define IGMP_HOST_MEMBERSHIP_R=
EPORT=A0 =A0=A0=A00x12=A0 =A0 /* Ditto */=0A85 #define IGMP_DVMRP=A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x13=A0 =A0 /* DVMRP routing */=0A86 #d=
efine IGMP_PIM=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x14=A0 =A0 /=
* PIM routing */=0A87 #define IGMP_TRACE=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 0x15=0A88 #define IGMPV2_HOST_MEMBERSHIP_REPORT=A0=A0=A00x16=A0 =
=A0 /* V2 version of 0x11 */=0A89 #define IGMP_HOST_LEAVE_MESSAGE=A0 =A0 =
=A0 =A0=A0=A00x17=0A90 #define IGMPV3_HOST_MEMBERSHIP_REPORT=A0=A0=A00x22=
=A0 =A0 /* V3 version of 0x11 */=0A=0AThe line 88 and 90 are about REPORT m=
essages.=0AThe IGMP_HOST_MEMBERSHIP_REPORT value is 0x12.=0ASo the comment =
on line 88 must be /* V2 version of 0x12 */,=0Aand the comment on line 90 m=
ust be /* V3 version of 0x12 */.=0A=0AHere is a patch.=0A=0AThank you,=0AFr=
ancois-Xavier Le Bail=0A=0A=0A      
--0-797806555-1294070616=:97776
Content-Type: text/x-diff; name="igmp_h.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="igmp_h.diff"

ZGlmZiAtcnUgYS9pbmNsdWRlL2xpbnV4L2lnbXAuaCBiL2luY2x1ZGUvbGlu
dXgvaWdtcC5oCi0tLSBhL2luY2x1ZGUvbGludXgvaWdtcC5oCTIwMTAtMDgt
MjcgMDE6NDc6MTIuMDAwMDAwMDAwICswMjAwCisrKyBiL2luY2x1ZGUvbGlu
dXgvaWdtcC5oCTIwMTAtMTItMTUgMDk6NTA6NDcuODA4MzYzMTQ0ICswMTAw
CkBAIC04NSw5ICs4NSw5IEBACiAjZGVmaW5lIElHTVBfRFZNUlAJCQkweDEz
CS8qIERWTVJQIHJvdXRpbmcgKi8KICNkZWZpbmUgSUdNUF9QSU0JCQkweDE0
CS8qIFBJTSByb3V0aW5nICovCiAjZGVmaW5lIElHTVBfVFJBQ0UJCQkweDE1
Ci0jZGVmaW5lIElHTVBWMl9IT1NUX01FTUJFUlNISVBfUkVQT1JUCTB4MTYJ
LyogVjIgdmVyc2lvbiBvZiAweDExICovCisjZGVmaW5lIElHTVBWMl9IT1NU
X01FTUJFUlNISVBfUkVQT1JUCTB4MTYJLyogVjIgdmVyc2lvbiBvZiAweDEy
ICovCiAjZGVmaW5lIElHTVBfSE9TVF9MRUFWRV9NRVNTQUdFIAkweDE3Ci0j
ZGVmaW5lIElHTVBWM19IT1NUX01FTUJFUlNISVBfUkVQT1JUCTB4MjIJLyog
VjMgdmVyc2lvbiBvZiAweDExICovCisjZGVmaW5lIElHTVBWM19IT1NUX01F
TUJFUlNISVBfUkVQT1JUCTB4MjIJLyogVjMgdmVyc2lvbiBvZiAweDEyICov
CiAKICNkZWZpbmUgSUdNUF9NVFJBQ0VfUkVTUAkJMHgxZQogI2RlZmluZSBJ
R01QX01UUkFDRQkJCTB4MWYK

--0-797806555-1294070616=:97776--
