From: Pekka Savola <pekkas@netcore.fi>
Subject: patch: ipv6 nexthop can be 6to4 address (fwd)
Date: Thu, 11 Mar 2004 15:04:28 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403111502180.16804-200000@netcore.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="1589707168-808551844-993326421=:13709"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.44.0403111502181.16804@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1589707168-808551844-993326421=:13709
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0403111502182.16804@netcore.fi>

FWIW --

Another user just complained about the stupidity of requiring using 
the "::a.b.c.d" format for creating a tunnel addess as "::/96" is 
so-called automatic tunneling using compatible addresses, which is 
deprecated -- and this has nothing to do with configured tunneling or 
6to4.

So, this is one way of allowing 6to4 addresses as a next-hop.  
Hopefully this gets fixed before the third anniversary of this 
problem..

---------- Forwarded message ----------
Date: Sat, 23 Jun 2001 23:00:21 +0300 (EEST)
From: Pekka Savola <pekkas@netcore.fi>
To: netdev@oss.sgi.com
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Subject: patch: ipv6 nexthop can be 6to4 address

Hi,

There's ongoing debate that ipv6 compatible addresses may get deprecated.
Some 6to4 relay routers don't support them anymore.  Thus it becomes
necessary to allow nexthop for the default route to native ipv6 to be a
6to4 address.

The current implementation basically assumes the only v6-over-v4 tunneling
method is automatic tunneling with compatible addresses.

Attached patch fixes this.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

--1589707168-808551844-993326421=:13709
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="linux-2.4.3-6to4-nexthop.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0106232300210.13709@netcore.fi>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="linux-2.4.3-6to4-nexthop.diff"

VGhlcmUncyBvbmdvaW5nIGRlYmF0ZSB0aGF0IGNvbXBhdGlibGUgYWRkcmVz
c2VzIG1heSBiZSBkZXByZWNhdGVkLiAgU29tZQ0KNnRvNCByZWxheSByb3V0
ZXJzIGRvbid0IHN1cHBvcnQgdGhlbSBhbnltb3JlLiAgVGh1cyBpdCBiZWNv
bWVzIG5lY2Vzc2FyeSB0bw0KYWxsb3cgbmV4dGhvcCBmb3IgdGhlIG5hdGl2
ZSBpcHY2IGRlZmF1bHQgcm91dGUgdG8gYmUgYSA2dG80IGFkZHJlc3MuICAN
Cg0KVGhlIGN1cnJlbnQgaW1wbGVtZW50YXRpb24gYmFzaWNhbGx5IGFzc3Vt
ZXMgdGhlIG9ubHkgdjYtb3Zlci12NCB0dW5uZWxpbmcgDQptZXRob2QgaXMg
YXV0b21hdGljIHR1bm5lbGluZyB3aXRoIGNvbXBhdGlibGUgYWRkcmVzc2Vz
Lg0KDQotLS0gbGludXgtMi40LjMvbmV0L2lwdjYvc2l0LmMJU2F0IEp1biAy
MyAxOTo0MDo1NiAyMDAxDQorKysgbGludXgtMi40LjMuZml4L25ldC9pcHY2
L3NpdC5jCVNhdCBKdW4gMjMgMTk6NTQ6MTIgMjAwMQ0KQEAgLTQ5NCwxMCAr
NDk0LDE1IEBADQogCQkJYWRkcl90eXBlID0gaXB2Nl9hZGRyX3R5cGUoYWRk
cjYpOw0KIAkJfQ0KIA0KLQkJaWYgKChhZGRyX3R5cGUgJiBJUFY2X0FERFJf
Q09NUEFUdjQpID09IDApDQotCQkJZ290byB0eF9lcnJvcl9pY21wOw0KKwkJ
LyogY2hlY2sgaWYgbmV4dGhvcCBmb3Igbm9uLTZ0bzQgYWRkcmVzcyBpcyA2
dG80IGFkZHJlc3MgKi8NCisJCWRzdCA9IHRyeV82dG80KGFkZHI2KTsNCisJ
CQ0KKwkJaWYgKCFkc3QpICB7DQorCQkJaWYgKChhZGRyX3R5cGUgJiBJUFY2
X0FERFJfQ09NUEFUdjQpID09IDApDQorCQkJCWdvdG8gdHhfZXJyb3JfaWNt
cDsNCiANCi0JCWRzdCA9IGFkZHI2LT5zNl9hZGRyMzJbM107DQorCQkJZHN0
ID0gYWRkcjYtPnM2X2FkZHIzMlszXTsNCisJCX0NCiAJfQ0KIA0KIAlpZiAo
aXBfcm91dGVfb3V0cHV0KCZydCwgZHN0LCB0aXBoLT5zYWRkciwgUlRfVE9T
KHRvcyksIHR1bm5lbC0+cGFybXMubGluaykpIHsNCg==
--1589707168-808551844-993326421=:13709--
