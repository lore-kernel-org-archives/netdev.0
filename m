From: =?utf-8?Q?Rog=C3=A9rio?= Brito <rbrito@ime.usp.br>
Subject: Re: [PATCH] powerpc: convert mace to netdev_ops
Date: Mon, 27 Apr 2009 11:20:25 -0300
Message-ID: <20090427142024.GC29608@ime.usp.br>
References: <20090426155708.GA23159@ime.usp.br>
	<20090426.230648.254087966.davem@davemloft.net>
	<20090427121633.GA29608@ime.usp.br>
	<20090427.054258.16622932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linuxppc-dev@ozlabs.org, paulus@samba.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090427.054258.16622932.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

SGksIERhdmUuCgpPbiBBcHIgMjcgMjAwOSwgRGF2aWQgTWlsbGVyIHdyb3RlOgo+IFlvdSBjYW4g
Zml4IHRoZSBtYWNlX3NldF90aW1lb3V0KCkgZnVuY3Rpb24gYXJndW1lbnRzIGJ5IGhhdmluZyBh
Cj4gaGVscGVyIGZ1bmN0aW9uIHRoYXQgc2ltcGx5IHdyYXBzIGFyb3VuZCBpdCBhbmQgcHJvdmlk
ZXMgdGhlIHNlY29uZAo+IGV4cGVjdGlvbiBvZiBhcmd1bWVudCB0eXBlcy4KCkh1bW1tLCB0aGlz
IG1lYW5zIHRoYXQgSSdtIG5vdCB0aGF0IGJhZC4uLiBUaGUgd3JhcHBlciBmdW5jdGlvbiB3YXMg
dGhlCmZpcnN0IHRoaW5nIHRoYXQgY2FtZSB0byBteSBtaW5kLCBidXQgSSBqdXN0IHdhbnRlZCB0
byBiZSBhcyBsZWFzdApkaXNydXB0aXZlIGFzIHBvc3NpYmxlLgoKPiBZb3VyIHBhdGNoIGlzIGFs
c28gd3JvbmcsIGl0J3MgbWlzc2luZyBhIGxvdCBvZiBuZXRkZXZfb3BzCj4gZW50cmllcyB0aGF0
IGFyZSBpbXBsaWNpdGx5IG9idGFpbmVkIHZpYSBhbGxvY19ldGhlcmRldigpLAo+IG5hbWVseToK
ClRoYW5rcyBmb3IgcG9pbnRpbmcgdGhvc2Ugb3V0LiBJIGRpZG4ndCBmaW5kIHRoZSBkb2N1bWVu
dGF0aW9uIGFib3V0Cm5ldGRldl9vcHMgdW5kZXIgRG9jdW1lbnRhdGlvbiAoYSBzaW1wbGUgZ3Jl
cCBkaWRuJ3QgdHVybiBhbnkgcmVzdWx0cykuCgo+IAkubmRvX2NoYW5nZV9tdHUJCT0gZXRoX2No
YW5nZV9tdHUsCj4gCS5uZG9fc2V0X21hY19hZGRyZXNzIAk9IGV0aF9tYWNfYWRkciwKPiAJLm5k
b192YWxpZGF0ZV9hZGRyCT0gZXRoX3ZhbGlkYXRlX2FkZHIsCgpOaWNlLiBJIHdpbGwgaW5jb3Jw
b3JhdGUgc3VjaCB0aGluZ3MuCgoKVGhhbmtzLCBSb2fDqXJpbyBCcml0by4KCi0tIApSb2fDqXJp
byBCcml0byA6IHJicml0b0B7bWFja2VuemllLGltZS51c3B9LmJyIDogR1BHIGtleSAxMDI0RC83
QzJDQUVCOApodHRwOi8vd3d3LmltZS51c3AuYnIvfnJicml0byA6IGh0dHA6Ly9tZXVzaXRlLm1h
Y2tlbnppZS5jb20uYnIvcmJyaXRvClByb2plY3RzOiBhbGdvcml0aG1zLmJlcmxpb3MuZGUgOiBs
YW1lLnNmLm5ldCA6IHZybXMuYWxpb3RoLmRlYmlhbi5vcmcKX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51
eHBwYy1kZXZAb3psYWJzLm9yZwpodHRwczovL296bGFicy5vcmcvbWFpbG1hbi9saXN0aW5mby9s
aW51eHBwYy1kZXY=
