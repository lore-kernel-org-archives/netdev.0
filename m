From: =?utf-8?B?U8O4cmVuc2VuLCBTdGVmYW4=?=
	<Stefan.Sorensen@spectralink.com>
Subject: Re: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Tue, 4 Feb 2014 15:24:27 +0000
Message-ID: <1391527464.7871.15.camel@e37108.spectralink.com>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
	 <20140204092939.GA9862@netboy>
	 <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
To: "ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0156.outbound.protection.outlook.com ([207.46.163.156]:36120
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbaBDPYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Feb 2014 10:24:30 -0500
In-Reply-To: <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Content-ID: <B4E4DB3E347CBB42B49B3753B0F6AEED@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE0LTAyLTA0IGF0IDEwOjUzICswMDAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiA+IE1vZHVsZXMgcGFyYW1ldGVycyBhcmUgc3VyZWx5IGVhc2llc3QgKGZvciB0aGUgZGV2ZWxv
cGVyKSwgYnV0IHBlcmhhcHMNCj4gPiB0aGUgdGltZSBoYXMgY29tZSBmb3IgdGhlICJyaWdodCB3
YXkuIg0KPiA+IA0KPiA+IEN1cnJlbnRseSB0aGVyZSBpcyBubyBpbnRlcmZhY2UgZm9yIGNvbmZp
Z3VyaW5nIHRoZSBHUElPcyB1c2VkIGJ5IFBIQw0KPiA+IGRldmljZXMsIGFuZCBsYXN0IHllYXIg
SSB3YXMgZ29pbmcgdG8gYWRkIHRoZSBHUElPcyB0byB0aGUgaWdiDQo+ID4gZHJpdmVyLiBUaGUg
Y29uY2x1c2lvbiBvZiB0aGUgZGlzY3Vzc2lvbiB3YXMgdGhhdCBtb2R1bGUgcGFyYW1ldGVycw0K
PiA+IGFyZSBiYWQgZm9yIHRoaXMsIGJ1dCBldGh0b29sIGlzIGdvb2QuDQo+ID4gDQo+ID4gICBo
dHRwOi8vd3d3LnNwaW5pY3MubmV0L2xpc3RzL25ldGRldi9tc2cyMzc2OTIuaHRtbA0KPiA+IA0K
PiA+IFsgSSBkaWQgbm90IGZvbGxvdyB0aHJvdWdoIHRvIGNvbWUgdXAgd2l0aCBhbiBldGh0b29s
IHdheSBvZiBjb25maWd1cmluZw0KPiA+ICAgdGhlIGlnYiBwaW5zLiBdDQo+ID4gDQo+ID4gRXZl
biB0aG91Z2ggaXQgaXMgbW9yZSB3b3JrLCBJIHRoaW5rIHRoZSB3YXkgZm9yd2FyZCBpcyB0byBp
bnZlbnQgYQ0KPiA+IHdheSB0byBsZXQgdGhlIHVzZXIgY29uZmlndXJlIHRoaXMga2luZCBvZiB0
aGluZyB2aWEgZXRodG9vbC4gV291bGQNCj4gPiB5b3UgY2FyZSB0byB0YWtlIGEgc3RhYiBhdCB0
aGlzPw0KPiANCj4gSXQgc2VlbXMgdG8gbWUgdGhhdCB0aGlzIGlzIGJvYXJkIGNvbmZpZ3VyYXRp
b24sIG5vdCB1c2VyIGNvbmZpZ3VyYXRpb24sDQo+IHNvIGl0IHNob3VsZCBiZSBkZWZpbmVkIGlu
IERUIG9yIEFDUEkgb3Igd2hhdGV2ZXIuDQo+IA0KPiBBcmUgdGhlcmUgYm9hcmRzIHdoaWNoIGV4
cG9zZSBtdWx0aXBsZSBHUElPcyBmb3IgdXNlcnMgdG8gcGx1ZyB0b2dldGhlcg0KPiBQUFMgc2ln
bmFscz8NCg0KSSB3b3VsZCBkZWZpbml0ZWx5IHByZWZlciB0aGUgRFQgYXBwcm9hY2guIE9uIGFs
bCB0aGUgcGxhdGZvcm1zIEkgaGF2ZQ0KdXNlZCwgdGhlIEdQSU8gY29uZmlndXJhdGlvbiBoYXMg
YmVlbiBzZXQgaW4gc3RvbmUgYnkgdGhlIEhXLiBCdXQgdGhlcmUNCm1pZ2h0IGJlIHNvbWUgZGV2
IGJvYXJkcyBvciB0aGUgbGlrZSB0aGF0IGhhcyB0aGVtIGNvbmZpZ3VyYWJsZS4NCg0KU3RlZmFu
DQo=
