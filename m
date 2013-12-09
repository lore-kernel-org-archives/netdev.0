From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 01/14] i40e: separate TSYNVALID and TSYNINDX fields
 in Rx descriptor
Date: Mon, 9 Dec 2013 19:33:58 +0000
Message-ID: <1386617638.24480.13.camel@jekeller-desk1.amr.corp.intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1386382643-29055-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZKXASf832Q7r+Sz_QU=nAFZVtQEa18etH97Xb-ECOnLag@mail.gmail.com>
	 <1386452451.2195.37.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58719 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755004Ab3LITeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 14:34:00 -0500
In-Reply-To: <1386452451.2195.37.camel@jtkirshe-mobl>
Content-Language: en-US
Content-ID: <6C36D4077C5545408D27074AA5EEB9FE@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gU2F0LCAyMDEzLTEyLTA3IGF0IDEzOjQwIC0wODAwLCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+
IE9uIFNhdCwgMjAxMy0xMi0wNyBhdCAyMzozMyArMDIwMCwgT3IgR2VybGl0eiB3cm90ZToNCj4g
PiBPbiBTYXQsIERlYyA3LCAyMDEzIGF0IDQ6MTcgQU0sIEplZmYgS2lyc2hlcg0KPiA+IDxqZWZm
cmV5LnQua2lyc2hlckBpbnRlbC5jb20+IHdyb3RlOg0KPiA+ID4gRnJvbTogSmFjb2IgS2VsbGVy
IDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+DQo+ID4gPg0KPiA+ID4gSW4gb3JkZXIgdG8gZ2V0
IDE1ODggdG8gd29yayBjb3JyZWN0bHkgdGhlIGRlZmluZXMgbmVlZCBhIGJpdA0KPiA+ID4gb2Yg
YSB0d2Vhay4NCj4gPiA+DQo+ID4gPiBDaGFuZ2UtSWQ6IEllNTBjZTJhMThlMTU5MzQ0MWYxNTYw
NDExZTVhNGY1MWM2ZDQ4YWFhDQo+ID4gDQo+ID4gSGkgSmVmZiwgd2UgYWxzbyB1c2UgdGhpcyB0
b2tlbiB3aXRoIG91dCBpbnRlcm5hbCBnZXJyaXQgc3lzdGVtIGJ1dA0KPiA+IG1ha2Ugc3VyZSB0
byBzdHJpcCB0aGF0IGJlZm9yZSBzZW5kaW5nIHVwc3RyZWFtLCBhcmUgd2UgT0sgZm9yDQo+ID4g
dXBzdHJlYW0gY29tbWl0IHRvIGNhcnJ5IHN1Y2ggdG9rZW5zIGZyb20gdGhlIHZlbmRvcnMgc3lz
dGVtcz8NCj4gPiANCj4gDQo+IEkgYXNrZWQgdGhhdCBxdWVzdGlvbiB0byBEYXZlIGxhc3Qgd2Vl
ayBhbmQgdG8gc3VtbWFyaXplIHRoZSBlbWFpbA0KPiB0aHJlYWQsICJpZiB0aGVyZSB3ZXJlIGNv
bW1pdCdzIGluIExpbnVzJ3MgdHJlZSB3aXRoIHRoZSBDaGFuZ2UtSWQNCj4gaW5mb3JtYXRpb24s
IHRoZW4gd2UgY291bGQgZG8gc29tZXRoaW5nIHNpbWlsYXIiLiAgV2Ugb3JpZ2luYWxseSB3ZXJl
DQo+IHVzaW5nICJJbnRlcm5hbCBJRDoiIGJ1dCBzaW5jZSB0aGVyZSB3YXMgc29tZSBkb2N1bWVu
dGVkIHVzZSBvZg0KPiAiQ2hhbmdlLUlkOiIsIHdlIGFkb3B0ZWQgdGhlIHVzZS4NCj4gDQoNClRv
IGNvbmZpcm0sIEkgZGlkIHRoZSBmb2xsb3dpbmcgb24gTGludXMnIHRyZWU6DQoNCiRnaXQgbG9n
IC0tZ3JlcD0nXkNoYW5nZS1JZDonIC0tb25lbGluZSB8IHdjIC1sDQoNCkkgZW5kZWQgdXAgd2l0
aCBqdXN0IG92ZXIgMTAwMCBwYXRjaGVzIG9uIGhpcyB0cmVlIHdpdGggdGhlIHRva2VuLg0KDQpS
ZWdhcmRzLA0KSmFrZQ0KDQo+ID4gDQo+ID4gDQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBKYWNvYiBL
ZWxsZXIgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT4NCj4gPiA+IFNpZ25lZC1vZmYtYnk6IEpl
c3NlIEJyYW5kZWJ1cmcgPGplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tPg0KPiA+ID4gVGVzdGVk
LWJ5OiBLYXZpbmR5YSBEZWVnYWxhIDxrYXZpbmR5YS5zLmRlZWdhbGFAaW50ZWwuY29tPg0KPiA+
ID4gU2lnbmVkLW9mZi1ieTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5j
b20+DQo+IA0KPiANCg0KDQo=
