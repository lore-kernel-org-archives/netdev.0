From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2 1/2] ixgbe: Fix
 tx_restart_queue/non_eop_desc statistics counters
Date: Tue, 15 Dec 2009 23:18:55 -0800 (PST)
Message-ID: <20091215.231855.107696050.davem@davemloft.net>
References: <20091215215636.25793.78144.stgit@localhost.localdomain>
	<20091215.211354.189718802.davem@davemloft.net>
	<20091215.231651.144154754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933747AbZLPHSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:18:54 -0500
In-Reply-To: <20091215.231651.144154754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxNSBE
ZWMgMjAwOSAyMzoxNjo1MSAtMDgwMCAoUFNUKQ0KDQo+IEZyb206IERhdmlkIE1pbGxlciA8ZGF2
ZW1AZGF2ZW1sb2Z0Lm5ldD4NCj4gRGF0ZTogVHVlLCAxNSBEZWMgMjAwOSAyMToxMzo1NCAtMDgw
MCAoUFNUKQ0KPiANCj4+IEZyb206IEplZmYgS2lyc2hlciA8amVmZnJleS50LmtpcnNoZXJAaW50
ZWwuY29tPg0KPj4gRGF0ZTogVHVlLCAxNSBEZWMgMjAwOSAxMzo1Njo1OSAtMDgwMA0KPj4gDQo+
Pj4gRnJvbTogTWFsbGlrYXJqdW5hIFIgQ2hpbGFrYWxhIDxtYWxsaWthcmp1bmEuY2hpbGFrYWxh
QGludGVsLmNvbT4NCj4+PiANCj4+PiBGaXggdGhlIHJlc3RhcnRfcXVldWUgYW5kIG5vbl9lb3Bf
ZGVzYyBjb3VudGVycyBmcm9tIGJlaW5nDQo+Pj4gZG91YmxlLWNvdW50ZWQuICBUaGV5IGFyZSBj
dW11bGF0aXZlIGluIGVhY2ggcmluZywgc28gd2UgZG9uJ3Qgd2FudCB0bw0KPj4+IGFkZCB0aGVt
IHRvIHRoZSBjdW11bGF0aXZlIHJlc3VsdCBpbiB0aGUgYWRhcHRlcidzIG1hc3RlciBjb3VudGVy
Lg0KPj4+IE90aGVyd2lzZSwgdGhlIHN0YXRzIHdpbGwgYmUgaW5hY2N1cmF0ZQ0KPj4+IA0KPj4+
IFNpZ25lZC1vZmYtYnk6ICBNYWxsaWthcmp1bmEgUiBDaGlsYWthbGEgPG1hbGxpa2FyanVuYS5j
aGlsYWthbGFAaW50ZWwuY29tPg0KPj4+IEFja2VkLWJ5OiBQZXRlciBQIFdhc2tpZXdpY3ogSnIg
PHBldGVyLnAud2Fza2lld2ljei5qckBpbnRlbC5jb20+DQo+Pj4gU2lnbmVkLW9mZi1ieTogSmVm
ZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQo+PiANCj4+IEFwcGxpZWQu
DQo+IA0KPiBTbyBob3cgZGlkIHlvdSBidWlsZCB0ZXN0IHRoaXM/DQo+IA0KPiBkcml2ZXJzL25l
dC9peGdiZS9peGdiZV9tYWluLmM6IEluIGZ1bmN0aW9uIKFpeGdiZV91cGRhdGVfc3RhdHOiOg0K
PiBkcml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmM6NDUzMjogZXJyb3I6IGludmFsaWQgdHlw
ZSBhcmd1bWVudCBvZiChLT6iIChoYXZlIKFzdHJ1Y3QgaXhnYmVfcmluZ6IpDQo+IGRyaXZlcnMv
bmV0L2l4Z2JlL2l4Z2JlX21haW4uYzo0NTM2OiBlcnJvcjogaW52YWxpZCB0eXBlIGFyZ3VtZW50
IG9mIKEtPqIgKGhhdmUgoXN0cnVjdCBpeGdiZV9yaW5noikNCg0KSSdtIG1ha2luZyB0aGUgb2J2
aW91cyBmaXggInMvLT4vLi8iLCBidXQgcmVhbGx5Li4uLg0KDQo=
