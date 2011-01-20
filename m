From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: undefined reference to 'nf_conntrack_tstamp_*'
Date: Thu, 20 Jan 2011 20:52:35 +0100
Message-ID: <4D389283.3040307@trash.net>
References: <20110120191612.24205.73463.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040303090502060502060402"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	pablo@netfilter.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110120191612.24205.73463.stgit@jf-dev1-dcblab>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040303090502060502060402
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Am 20.01.2011 20:16, schrieb John Fastabend:
> net/built-in.o: In function `nf_conntrack_init_net':
> net/netfilter/nf_conntrack_core.c:1521:
> 	undefined reference to `nf_conntrack_tstamp_init'
> net/netfilter/nf_conntrack_core.c:1531:
> 	undefined reference to `nf_conntrack_tstamp_fini'
> 
> Add 'selects' notation to Kconfig to include NF_CONNTRACK_TIMESTAMP
> this resolves all the config files I tested.

That's not the correct fix, NF_CONNTRACK_TIMESTAMP is supposed
to be option. Please try whether this patch fixes the problem.


--------------040303090502060502060402
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="x"

Y29tbWl0IDJmMWUzMTc2NzIzZDc0ZWEyZGQ5NzVlNWJlMGVmNmJiNGZlZDJlMmUKQXV0aG9y
OiBQYXRyaWNrIE1jSGFyZHkgPGthYmVyQHRyYXNoLm5ldD4KRGF0ZTogICBUaHUgSmFuIDIw
IDIwOjQ2OjUyIDIwMTEgKzAxMDAKCiAgICBuZXRmaWx0ZXI6IG5mX2Nvbm50cmFjazogZml4
IGxpbmtlciBlcnJvciB3aXRoIE5GX0NPTk5UUkFDS19USU1FU1RBTVA9bgogICAgCiAgICBu
ZXQvYnVpbHQtaW4ubzogSW4gZnVuY3Rpb24gYG5mX2Nvbm50cmFja19pbml0X25ldCc6CiAg
ICBuZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19jb3JlLmM6MTUyMToKICAgIAl1bmRlZmlu
ZWQgcmVmZXJlbmNlIHRvIGBuZl9jb25udHJhY2tfdHN0YW1wX2luaXQnCiAgICBuZXQvbmV0
ZmlsdGVyL25mX2Nvbm50cmFja19jb3JlLmM6MTUzMToKICAgIAl1bmRlZmluZWQgcmVmZXJl
bmNlIHRvIGBuZl9jb25udHJhY2tfdHN0YW1wX2ZpbmknCiAgICAKICAgIEFkZCBkdW1teSBp
bmxpbmUgZnVuY3Rpb25zIGZvciB0aGUgPW4gY2FzZSB0byBmaXggdGhpcy4KICAgIAogICAg
UmVwb3J0ZWQtYnk6IEpvaG4gRmFzdGFiZW5kIDxqb2huLnIuZmFzdGFiZW5kQGludGVsLmNv
bT4KICAgIFNpZ25lZC1vZmYtYnk6IFBhdHJpY2sgTWNIYXJkeSA8a2FiZXJAdHJhc2gubmV0
PgoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25ldGZpbHRlci9uZl9jb25udHJhY2tfdGlt
ZXN0YW1wLmggYi9pbmNsdWRlL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX3RpbWVzdGFt
cC5oCmluZGV4IGYxN2RjYjYuLmZjOWM4MmIgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L25l
dGZpbHRlci9uZl9jb25udHJhY2tfdGltZXN0YW1wLmgKKysrIGIvaW5jbHVkZS9uZXQvbmV0
ZmlsdGVyL25mX2Nvbm50cmFja190aW1lc3RhbXAuaApAQCAtNDcsNyArNDcsMTkgQEAgc3Rh
dGljIGlubGluZSB2b2lkIG5mX2N0X3NldF90c3RhbXAoc3RydWN0IG5ldCAqbmV0LCBib29s
IGVuYWJsZSkKIAluZXQtPmN0LnN5c2N0bF90c3RhbXAgPSBlbmFibGU7CiB9CiAKKyNpZmRl
ZiBDT05GSUdfTkZfQ09OTlRSQUNLX1RJTUVTVEFNUAogZXh0ZXJuIGludCBuZl9jb25udHJh
Y2tfdHN0YW1wX2luaXQoc3RydWN0IG5ldCAqbmV0KTsKIGV4dGVybiB2b2lkIG5mX2Nvbm50
cmFja190c3RhbXBfZmluaShzdHJ1Y3QgbmV0ICpuZXQpOworI2Vsc2UKK3N0YXRpYyBpbmxp
bmUgaW50IG5mX2Nvbm50cmFja190c3RhbXBfaW5pdChzdHJ1Y3QgbmV0ICpuZXQpCit7CisJ
cmV0dXJuIDA7Cit9CisKK3N0YXRpYyBpbmxpbmUgdm9pZCBuZl9jb25udHJhY2tfdHN0YW1w
X2Zpbmkoc3RydWN0IG5ldCAqbmV0KQoreworCXJldHVybjsKK30KKyNlbmRpZiAvKiBDT05G
SUdfTkZfQ09OTlRSQUNLX1RJTUVTVEFNUCAqLwogCiAjZW5kaWYgLyogX05GX0NPTk5UUkFD
S19UU1RBTVBfSCAqLwo=
--------------040303090502060502060402--
