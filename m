From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Bug#572201: forcedeth driver hangs under heavy load
Date: Wed, 14 Apr 2010 01:33:15 -0400
Message-ID: <4BC5539B.6050908@nvidia.com>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop>	 <20100413.144340.138717714.davem@davemloft.net> <1271195179.16881.575.camel@edumazet-laptop>
Reply-To: Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070606080700040903080308"
Cc: David Miller <davem@davemloft.net>,
 "smulcahy@gmail.com" <smulcahy@gmail.com>,
 "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "ben@decadent.org.uk" <ben@decadent.org.uk>,
 "572201@bugs.debian.org" <572201@bugs.debian.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.572201.B572201.127120903229193@bugs.debian.org>
In-Reply-To: <1271195179.16881.575.camel@edumazet-laptop>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070606080700040903080308
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Attached fix has been submitted to netdev.

Ayaz


Eric Dumazet wrote:
> Le mardi 13 avril 2010 =C3=A0 14:43 -0700, David Miller a =C3=A9crit :
>=20
>>Do you really come to the conclusion that TSO is broken with the above
>>test results?
>>
>>I would conclude that there is a TX checksumming issue, since merely
>>turning TSO off does not fix the problem whereas turning TX
>>checksumming off does.
>=20
>=20
> Indeed, we clarified the point and it is a TX checksum issue.
>=20
>=20

--------------070606080700040903080308
Content-Type: text/plain;
 name="patch-forcedeth-tx-limit2-fix"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch-forcedeth-tx-limit2-fix"

LS0tIG9sZC9kcml2ZXJzL25ldC9mb3JjZWRldGguYwkyMDEwLTA0LTE0IDAxOjE4OjUxLjAw
MDAwMDAwMCAtMDQwMAorKysgbmV3L2RyaXZlcnMvbmV0L2ZvcmNlZGV0aC5jCTIwMTAtMDQt
MTQgMDE6MjA6NDAuMDAwMDAwMDAwIC0wNDAwCkBAIC01OTAxLDcgKzU5MDEsNyBAQAogCS8q
IExpbWl0IHRoZSBudW1iZXIgb2YgdHgncyBvdXRzdGFuZGluZyBmb3IgaHcgYnVnICovCiAJ
aWYgKGlkLT5kcml2ZXJfZGF0YSAmIERFVl9ORUVEX1RYX0xJTUlUKSB7CiAJCW5wLT50eF9s
aW1pdCA9IDE7Ci0JCWlmICgoaWQtPmRyaXZlcl9kYXRhICYgREVWX05FRURfVFhfTElNSVQy
KSAmJgorCQlpZiAoKChpZC0+ZHJpdmVyX2RhdGEgJiBERVZfTkVFRF9UWF9MSU1JVDIpID09
IERFVl9ORUVEX1RYX0xJTUlUMikgJiYKIAkJICAgIHBjaV9kZXYtPnJldmlzaW9uID49IDB4
QTIpCiAJCQlucC0+dHhfbGltaXQgPSAwOwogCX0K
--------------070606080700040903080308--
