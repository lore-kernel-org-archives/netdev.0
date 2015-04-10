From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v3 2/2] ixgbe: Add the
 appropriate ethtool ops to query RSS indirection table and key
Date: Fri, 10 Apr 2015 23:07:31 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F812F93@ORSMSX108.amr.corp.intel.com>
References: <1427739538-1038-1-git-send-email-vladz@cloudius-systems.com>
 <1427739538-1038-3-git-send-email-vladz@cloudius-systems.com>
 <1427758652.2497.101.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33186 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933252AbbDJXHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 19:07:33 -0400
In-Reply-To: <1427758652.2497.101.camel@jtkirshe-mobl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSW50ZWwtd2lyZWQtbGFu
IFttYWlsdG86aW50ZWwtd2lyZWQtbGFuLWJvdW5jZXNAbGlzdHMub3N1b3NsLm9yZ10gT24NCj4g
QmVoYWxmIE9mIEplZmYgS2lyc2hlcg0KPiBTZW50OiBNb25kYXksIE1hcmNoIDMwLCAyMDE1IDQ6
MzggUE0NCj4gVG86IFZsYWQgWm9sb3Rhcm92DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3Jn
OyBhdmlAY2xvdWRpdXMtc3lzdGVtcy5jb207IGludGVsLXdpcmVkLQ0KPiBsYW5AbGlzdHMub3N1
b3NsLm9yZzsgZ2xlYkBjbG91ZGl1cy1zeXN0ZW1zLmNvbQ0KPiBTdWJqZWN0OiBSZTogW0ludGVs
LXdpcmVkLWxhbl0gW1BBVENIIG5ldC1uZXh0IHYzIDIvMl0gaXhnYmU6IEFkZCB0aGUNCj4gYXBw
cm9wcmlhdGUgZXRodG9vbCBvcHMgdG8gcXVlcnkgUlNTIGluZGlyZWN0aW9uIHRhYmxlIGFuZCBr
ZXkNCj4gDQo+IE9uIE1vbiwgMjAxNS0wMy0zMCBhdCAyMToxOCArMDMwMCwgVmxhZCBab2xvdGFy
b3Ygd3JvdGU6DQo+ID4gQWRkZWQgZ2V0X3J4ZmhfaW5kaXJfc2l6ZSwgZ2V0X3J4Zmhfa2V5X3Np
emUgYW5kIGdldF9yeGZoIGV0aHRvb2xfb3BzDQo+ID4gY2FsbGJhY2tzIGltcGxlbWVudGF0aW9u
cy4NCj4gPg0KPiA+IFRoaXMgZW5hYmxlcyB0aGUgZXRodG9vbCdzICIteCIgYW5kICItLXNob3ct
cnhmaFstaW5kaXJdIiBvcHRpb25zLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogVmxhZCBab2xv
dGFyb3YgPHZsYWR6QGNsb3VkaXVzLXN5c3RlbXMuY29tPg0KPiA+IC0tLQ0KPiA+ICBkcml2ZXJz
L25ldC9ldGhlcm5ldC9pbnRlbC9peGdiZS9peGdiZS5oICAgICAgICAgfCAgMSArDQo+ID4gIGRy
aXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX2V0aHRvb2wuYyB8IDQyDQo+ID4g
KysrKysrKysrKysrKysrKysrKysrKysrDQo+ID4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2l4Z2JlL2l4Z2JlX21haW4uYyAgICB8ICAyICstDQo+ID4gIDMgZmlsZXMgY2hhbmdlZCwgNDQg
aW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gVGhhbmtzIFZsYWQsIEkgaGF2ZSBh
ZGRlZCB5b3VyIHBhdGNoIHRvIG15IHF1ZXVlLg0KPiAtLQ0KPiBnaXQ6Ly9naXQua2VybmVsLm9y
Zy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvamtpcnNoZXIvbmV4dC1xdWV1ZS5naXQNCj4gZGV2
LXF1ZXVlDQoNClRlc3RlZC1ieTogUGhpbCBTY2htaXR0IDxwaGlsbGlwLmouc2NobWl0dEBpbnRl
bC5jb20+DQo=
