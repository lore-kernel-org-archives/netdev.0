From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue, 8 Dec 2015 19:40:43 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077019AA972@SHSMSX103.ccr.corp.intel.com>
References: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
 <56671E59.40402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"dsahern@gmail.com" <dsahern@gmail.com>,
	"tj@kernel.org" <tj@kernel.org>,
	"cascardo@redhat.com" <cascardo@redhat.com>,
	"corbet@lwn.net" <corbet@lwn.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bwh@kernel.org" <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16352 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbbLHTks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 14:40:48 -0500
In-Reply-To: <56671E59.40402@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gT24gMDcvMTIvMTUgMjA6NDIsIGthbi5saWFuZ0BpbnRlbC5jb20gd3JvdGU6DQo+ID4g
RnJvbTogS2FuIExpYW5nIDxrYW4ubGlhbmdAaW50ZWwuY29tPg0KPiA+DQo+ID4gSW50cmRvdWNl
ICJxdWV1ZSIgb3B0aW9uIGZvciBjb2FsZXNjZSBnZXR0aW5nIGFuZCBzZXR0aW5nLg0KPiA+IEZv
ciBjb2FsZXNjZSBnZXR0aW5nLCBvbmx5IHRoZSBjb2FsZXNjaW5nIHBhcmFtZXRlcnMgZnJvbSBz
cGVjaWZpYw0KPiA+IHF1ZXVlIHdpbGwgYmUgcGFzc2VkIHRvIHVzZXIgc3BhY2UuDQo+ID4gRm9y
IGNvYWxlc2NlIHNldHRpbmcsIHRoZSBjb2FsZXNjaW5nIHBhcmFtZXRlcnMgd2lsbCBvbmx5IGJl
IGFwcGxpZWQNCj4gPiB0byBzcGVjaWZpYyBxdWV1ZS4NCj4gPiBJZiB0aGUgcXVldWUgaXMgc2V0
IHRvIC0xLCB0aGUgY29hbGVzY2luZyBwYXJhbWV0ZXJzIHdpbGwgYXBwbHkgdG8gYWxsDQo+ID4g
cXVldWVzLg0KPiANCj4gVGhpcyBsb29rcyBsaWtlIGEgZ29vZCBzdGFydCwgYnV0IHRoZXJlIGFy
ZSBhIGZldyB0aGluZ3MgdGhhdCBuZWVkIHRvIGJlDQo+IGNsYXJpZmllZCwgaW4gcGFydGljdWxh
cjoNCj4gDQo+IC0gaWYgdGhlIG51bWJlciBvZiBUWCBhbmQgUlggcXVldWVzIGRpZmZlciwgYnV0
IHRoZSBldGh0b29sIGNvYWxlc2NlDQo+IHN0cnVjdHVyZSBjb250YWlucyBwYXJhbWV0ZXJzIHRo
YXQgYWZmZWN0IGJvdGggdGhlIFJYIGFuZCBUWCBzaWRlLCBhbmQgdGhlDQo+IHF1ZXVlIG51bWJl
ciBpcyBpbnZhbGlkL25vbi1leGlzdGVudCBmb3Igb25lIG9mIHRoZXNlIHNpZGVzLCB3aGF0IGlz
IHRoZQ0KPiBleHBlY3RlZCBvdXRjb21lPyBTYW1lIHF1ZXN0aW9uIHdpdGggc3BlY2lmeWluZyBh
IHF1ZXVlIG51bWJlciwgd2l0aA0KPiBSWCBxdWV1ZSBOIG5vdCBiZWxvbmdpbmcgdG8gdGhlIHNh
bWUgcXVldWUgcGFpciBhcyBUWCBxdWV1ZSBOPw0KPg0KSSB0aGluZyBJIHNob3VsZCBpbnRyb2R1
Y2UgInR4X3F1ZXVlIiBhbmQgInJ4X3F1ZXVlIiBzZXBhcmF0ZWx5DQppbiBuZXh0IHZlcnNpb24u
DQogDQo+IC0gZnJvbSBhbiB1c2VyIHBlcnNwZWN0aXZlIGRvIHdlIHdhbnQgdG8gaXRlcmF0ZSBv
dmVyIGFsbCBxdWV1ZXMgdG8gc2V0DQo+IHRoZWlyIHBhcmFtZXRlcnMsIG9yIHNob3VsZCB3ZSBo
YXZlIGEgcXVldWUgYml0bWFzayBwYXJhbWV0ZXIgd2hpY2gNCj4gYWxsb3dzIHNldHRpbmcgdGhl
bSB3aXRoIHRoZSBzYW1lIHNldHRpbmdzIGluIG9uZSBzaG90PyBXaGF0IHdvdWxkIGJlDQo+IHRo
ZSBhcHByb3ByaWF0ZSBiaXRtYXNrIHNpemUgdGhlbiAoMzItYml0cyB3aXRoIDE2LWJpdHMgZm9y
IFRYIGFuZCAxNi1iaXRzDQo+IGZvciBSWCBtaWdodCBiZSB0b28gc21hbGwpPw0KPiANCg0KSXQn
cyBhIGdvb2QgaWRlYSB0byB1c2UgcXVldWUgYml0bWFzaywgaG93ZXZlciBJIGhhdmUgbm8gaWRl
YSBob3cgbWFueQ0KQml0cyBzaG91bGQgd2UgcmVzZXJ2ZSBmb3IgVFggYW5kIFJYIHF1ZXVlcy4N
CkZvciBteSB0ZXN0IHBsYXRmb3JtLCB0aGVyZSBhcmUgNDggcXVldWUgcGFpci4gU28gNDggYml0
cyBhcmUgbmVlZGVkIGZvciBUWA0KYW5kIGFub3RoZXIgNDggYml0cyBmb3IgUlguDQpUaGVyZSBj
b3VsZCBiZSBtb3JlIHF1ZXVlcyBpbiBvdGhlciBwbGFyZm9ybXMuLi4NCg0KVGhhbmtzLA0KS2Fu
DQo=
