From: "Parikh, Neerav" <neerav.parikh@intel.com>
Subject: RE: [net-next 07/15] i40e: Separate out DCB capability and enabled
 flags
Date: Thu, 12 Jun 2014 16:59:20 +0000
Message-ID: <739353123C992A4C8800D77E209425907ECD55FC@ORSMSX103.amr.corp.intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1402504404-8954-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJZOPZLQ+OUgkHpaSr_aEYLLvyeEHMVwXaruUnj5JZxZ1Wm5RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33079 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbaFLQ7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 12:59:55 -0400
In-Reply-To: <CAJZOPZLQ+OUgkHpaSr_aEYLLvyeEHMVwXaruUnj5JZxZ1Wm5RQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogT3IgR2VybGl0eiBbbWFp
bHRvOm9yLmdlcmxpdHpAZ21haWwuY29tXQ0KPiBTZW50OiBUaHVyc2RheSwgSnVuZSAxMiwgMjAx
NCAxOjIyIEFNDQo+IFRvOiBLaXJzaGVyLCBKZWZmcmV5IFQNCj4gQ2M6IERhdmlkIE1pbGxlcjsg
UGFyaWtoLCBOZWVyYXY7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGdvc3BvQHJlZGhhdC5jb207
DQo+IHNhc3NtYW5uQHJlZGhhdC5jb20NCj4gU3ViamVjdDogUmU6IFtuZXQtbmV4dCAwNy8xNV0g
aTQwZTogU2VwYXJhdGUgb3V0IERDQiBjYXBhYmlsaXR5IGFuZCBlbmFibGVkDQo+IGZsYWdzDQo+
IA0KPiBPbiBXZWQsIEp1biAxMSwgMjAxNCBhdCA3OjMzIFBNLCBKZWZmIEtpcnNoZXINCj4gPGpl
ZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gRnJvbTogTmVlcmF2IFBhcmlr
aCA8bmVlcmF2LnBhcmlraEBpbnRlbC5jb20+DQo+ID4NCj4gPiBDdXJyZW50bHkgaWYgdGhlIGZp
cm13YXJlIHJlcG9ydHMgRENCIGNhcGFiaWxpdHkgdGhlIGRyaXZlciBlbmFibGVzDQo+ID4gSTQw
RV9GTEFHX0RDQl9FTkFCTEVEIGZsYWcuIFdoZW4gdGhpcyBmbGFnIGlzIGVuYWJsZWQgdGhlIGRy
aXZlcg0KPiA+IGluc2VydHMgYSB0YWcgd2hlbiB0cmFuc21pdHRpbmcgYSBwYWNrZXQgZnJvbSB0
aGUgcG9ydA0KPiANCj4gd2hhdCBpcyB0aGlzIHRhZyAodmxhbj8pIGFuZCBob3cgaXQncyBkZXRl
cm1pbmVkPw0KPg0KWWVzIGl0J3MgYSB2bGFuIHRhZy4gSW4gYSBEQ0IgZW52aXJvbm1lbnQgdHJh
ZmZpYyB3aWxsIGJlIHR5cGljYWxseSBwcmlvcml0eSB0YWdnZWQNCmFwYXJ0IGZyb20gdGhlIGNv
bnRyb2wgcHJvdG9jb2xzIChlLmcuIExMRFApIHdpY2ggYXJlIHNlbnQgdW50YWdnZWQuIA0KQWRt
aW5pc3RyYXRvcnMgd2lsbCBjb25maWd1cmUgdGhlIHZsYW5zIGJhc2VkIG9uIHRoZWlyIG5ldHdv
cmsgY29uZmlndXJhdGlvbiANCmFuZCBhcHBsaWNhdGlvbnMgdGhhdCBuZWVkcyBhIHBhcnRpY3Vs
YXIgUW9TIHNldHMgdGhlIHNrYiBwcmlvcml0eS4NCkZDb0UgaXMgYW4gZXhhbXBsZSBvZiBzdWNo
IGFuIGFwcGxpY2F0aW9uLiANCg0KV2hhdCBzaG91bGQgYmUgdGhlIHByaW9yaXR5IGZvciBhIHBh
cnRpY3VsYXIgYXBwbGljYXRpb24gaXMgdHlwaWNhbGx5IGRldGVybWluZWQgDQp2aWEgRENCWC4N
CiANCj4gPiBldmVuIGlmIHRoZXJlIGFyZSBubyBEQ0IgdHJhZmZpYyBjbGFzc2VzIGNvbmZpZ3Vy
ZWQgYXQgdGhlIHBvcnQuDQo=
