From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Fix target address for (proxy/anycast) NA
Date: Wed, 20 Aug 2003 14:23:12 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308192019030.27510-200000@rhea.tcs.hut.fi>
References: <20030819083621.2ae4abc8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-782513297-1061378592=:541"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <20030819083621.2ae4abc8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-782513297-1061378592=:541
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

the target address in neighbor advertisements must be the solicited
address. Otherwise proxy NAs (and NAs for anycast addresses) don't work.
Please apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257


---377318441-782513297-1061378592=:541
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ndisc_na_target.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0308201423120.541@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ndisc_na_target.patch"

LS0tIGxpbnV4LTIuNS5PTEQvbmV0L2lwdjYvbmRpc2MuYwkyMDAzLTA4LTIw
IDE0OjA5OjEzLjAwMDAwMDAwMCArMDMwMA0KKysrIGxpbnV4LTIuNS9uZXQv
aXB2Ni9uZGlzYy5jCTIwMDMtMDgtMjAgMTQ6MDk6MjguMDAwMDAwMDAwICsw
MzAwDQpAQCAtNDg1LDcgKzQ4NSw3IEBADQogICAgICAgICBtc2ctPmljbXBo
LmljbXA2X292ZXJyaWRlICA9ICEhb3ZlcnJpZGU7DQogDQogICAgICAgICAv
KiBTZXQgdGhlIHRhcmdldCBhZGRyZXNzLiAqLw0KLQlpcHY2X2FkZHJfY29w
eSgmbXNnLT50YXJnZXQsIHNyY19hZGRyKTsNCisJaXB2Nl9hZGRyX2NvcHko
Jm1zZy0+dGFyZ2V0LCBzb2xpY2l0ZWRfYWRkcik7DQogDQogCWlmIChpbmNf
b3B0KQ0KIAkJbmRpc2NfZmlsbF9vcHRpb24obXNnLT5vcHQsIE5EX09QVF9U
QVJHRVRfTExfQUREUiwgZGV2LT5kZXZfYWRkciwgZGV2LT5hZGRyX2xlbik7
DQo=
---377318441-782513297-1061378592=:541--
