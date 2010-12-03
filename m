From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix link behavior for SFP+ when
 driver is brought down
Date: Fri, 3 Dec 2010 14:46:14 -0800
Message-ID: <A78C6259B11833419567082E2DC0C25601D877D4D5@orsmsx508.amr.corp.intel.com>
References: <20101203133151.21637.52883.stgit@localhost.localdomain>
 <20101203.094215.229763630.davem@davemloft.net>
 <20101203.101512.15225225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_A78C6259B11833419567082E2DC0C25601D877D4D5orsmsx508amrc_"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10484 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873Ab0LCWqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Dec 2010 17:46:16 -0500
In-Reply-To: <20101203.101512.15225225.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_A78C6259B11833419567082E2DC0C25601D877D4D5orsmsx508amrc_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

T24gRnJpLCAyMDEwLTEyLTAzIGF0IDEwOjE1IC0wODAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6Cj4g
RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pgo+IERhdGU6IEZyaSwgMDMg
RGVjIDIwMTAgMDk6NDI6MTUgLTA4MDAgKFBTVCkKPiAKPiA+IEkgZml4ZWQgYWxsIG9mIHRoaXMg
dXAgYW5kIGFwcGxpZWQgaXQgYWxsLCBidXQgdGhpcyBzb3J0IG9mIHN0dWZmCj4gPiBuZWVkcyB0
byBiZSBzb3J0ZWQgb3V0IGJlZm9yZSBJIHNlZSB0aGUgc3VibWlzc2lvbi4gOi0pCj4gCj4gVGhl
c2UgcGF0Y2hlcyBpbnRyb2R1Y2VkIHRoZSBmb2xsb3dpbmcgbmV3IGNvbXBpbGUgd2FybmluZ3Ms
Cj4gcGxlYXNlIHNlbmQgbWUgcGF0Y2hlcyB0byBmaXggdGhlbToKPiAKPiBkcml2ZXJzL25ldC9p
eGdiZS9peGdiZV9tYWluLmM6IEluIGZ1bmN0aW9uICdpeGdiZV91cF9jb21wbGV0ZSc6Cj4gZHJp
dmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jOjM4MDM6MjI6IHdhcm5pbmc6IGNvbXBhcmlzb24g
YmV0d2VlbiAnZW51bSBpeGdiZV9waHlfdHlwZScgYW5kICdlbnVtIGl4Z2JlX21lZGlhX3R5cGUn
Cj4gZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jOiBJbiBmdW5jdGlvbiAnaXhnYmVfZG93
bic6Cj4gZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jOjQxMjU6MjI6IHdhcm5pbmc6IGNv
bXBhcmlzb24gYmV0d2VlbiAnZW51bSBpeGdiZV9waHlfdHlwZScgYW5kICdlbnVtIGl4Z2JlX21l
ZGlhX3R5cGUnCj4gZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jOiBJbiBmdW5jdGlvbiAn
aXhnYmVfcHJvYmUnOgo+IGRyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX21haW4uYzo3MjE1OjIyOiB3
YXJuaW5nOiBjb21wYXJpc29uIGJldHdlZW4gJ2VudW0gaXhnYmVfcGh5X3R5cGUnIGFuZCAnZW51
bSBpeGdiZV9tZWRpYV90eXBlJwo+IAo+IFRoYW5rcy4KClZlcnkgaW50ZXJlc3RpbmcgdGhhdCB3
ZSBkaWQgbm90IHNlZSB0aGlzIGR1cmluZyBvdXIgY29tcGlsZSB0ZXN0aW5nIG9mCnRoZSBwYXRj
aC4gIERvbiBpcyB3b3JraW5nIG9uIGEgcGF0Y2ggcmlnaHQgbm93IHRvIGZpeCB0aGUgaXNzdWUu
Cg==

--_002_A78C6259B11833419567082E2DC0C25601D877D4D5orsmsx508amrc_
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: signature.asc
Content-Disposition: attachment; filename="signature.asc"; size=491;
	creation-date="Fri, 03 Dec 2010 14:46:14 GMT";
	modification-date="Fri, 03 Dec 2010 14:46:14 GMT"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuNC4xMSAoR05V
L0xpbnV4KQoKaVFFY0JBQUJBZ0FHQlFKTStYTXVBQW9KRUNUc0NBRHIvRVdVOFgwSUFJVWdsTUdZ
ZTRFVitQUVBOZmxsVDFTWgp6elJaSWlqejQ3SDRBVFdBNXdJM2ZRV0hBbVZ2eDZoVDhGRDF4UWVL
SUVEdUM3d0Q2eVp5WVBsaDVKaTd2cUlHCm0vbWZIOE5xNGFXUTFoOGI5Q3NFTi81VlA4VTdxMVZi
UTRyT1hoTGFtNDAvVHJoQTBXOUNYQUNKM1hlRWVHazMKLytIOE1rNVlJTld2L1lkdUY5V3lDV05C
bUdMZW9BMk51KzYzbU9VSk1XM0RPaFI1ZjBiZmJKVTgwR092cS9XbApRZGZSek0yMW5TMXBZTXJX
RGdGMHhZaGp5YWVYSGhOTnZMbVl3MlM3SnZBbG1GWG45QTQrd3cxNlMvOXRzMkxVCkNHbzl5ZTJQ
cTl0d1JmeGlLWlR1bHl1Q2RsZ1dWSVluL0E1NG4rcmJYYWdJdVlWNVM4WWxlWGtNbTBnK2JXZz0K
PXJBbHgKLS0tLS1FTkQgUEdQIFNJR05BVFVSRS0tLS0tCgo=

--_002_A78C6259B11833419567082E2DC0C25601D877D4D5orsmsx508amrc_--
