From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 2 Apr 2013 22:23:54 +0000
Message-ID: <157393863283F442885425D2C45428564F202B2A@nasanexd02f.na.qualcomm.com>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com>
 <20100125.163612.582489483209420341.anders@netinsight.net>
 <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com>
 <20100126.093439.651115405791675606.anders@netinsight.net>
 <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk>
 <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com>
 <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk>
 <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com>
 <20130402211524.GE4924@order.stressinduktion.org>
 <157393863283F442885425D2C45428564F202AD5@nasanexd02f.na.qualcomm.com>
 <20130402221913.GG4924@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <ben@decadent.org.uk>,
	=?utf-8?B?QW5kZXJzIEJvc3Ryw7Zt?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:40023 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761998Ab3DBWXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 18:23:55 -0400
In-Reply-To: <20130402221913.GG4924@order.stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IA0KPiBPbiBUdWUsIEFwciAwMiwgMjAxMyBhdCAwOTo1MToxMlBNICswMDAwLCBIdWFuZywg
WGlvbmcgd3JvdGU6DQo+ID4gPiBUaGUgZXJyb3IgdmFuaXNoZXMgYXMgc29vbiBhcyBJIHB1dCBh
IGdzbyBzaXplIGxpbWl0IG9mDQo+ID4gPiBNQVhfVFhfQlVGX0xFTiBpbiB0aGUgZHJpdmVyLiBN
QVhfVFhfQlVGX0xFTiBzZWVtcyB0byBiZQ0KPiBhcmJpdHJhcnkNCj4gPiA+IHNldCB0byAweDIw
MDAuIEkgY2FuIGV2ZW4gcmFpc2UgaXQgdG8gMHgzMDAwIGFuZCBkb24ndCBzZWUgYW55IHRjcA0K
PiA+ID4gcmV0cmFuc21pdHMuIERvIHlvdSBoYXZlIGFuIGFkdmljZSBvbiBob3cgdG8gc2l6ZSB0
aGlzIHZhbHVlIChlLmcuIHNob3VsZA0KPiB3ZSBzd2l0Y2ggdG8gdGhlIHdpbmRvd3MgdmFsdWVz
KT8NCj4gPiA+DQo+ID4NCj4gPiBXb3VsZCB5b3UgdHJ5IDB4NDAwMCA/IGJlY2F1c2UgdGhlIGJ1
ZmZlci1sZW5ndGggaW4gVFggZGVzY3JpcHRvciBpcyAxNGJpdHMsDQo+IDB4NDAwMCBleGNlZWRz
IG1heCB2YWx1ZS4NCj4gPiBEbyB5b3UgZmluZCBhbnkgYnVnL2lzc3VlIG9uIHRoZSBjb2RlIHRo
YXQgY2FsY3VsYXRlIHRoZSBsZW5ndGggZm9yIGVhY2ggVFgNCj4gZGVzY3JpcHRvciA/DQo+IA0K
PiBTZXR0aW5nIE1BWF9UWF9CVUZfTEVOIHRvIDB4NDAwMA0KPiANCj4gWyA4OTQ5LjgzMzc1MF0g
QVRMMUUgMDAwMDowNDowMC4wIHAzM3AxOiBOSUMgTGluayBpcyBVcCA8MTAwIE1icHMgRnVsbA0K
PiBEdXBsZXg+IFsgODk0OS44MzM3ODNdIElQdjY6IEFERFJDT05GKE5FVERFVl9DSEFOR0UpOiBw
MzNwMTogbGluaw0KPiBiZWNvbWVzIHJlYWR5IFsgODk2MC44NjE1NTddIEFUTDFFIDAwMDA6MDQ6
MDAuMCBwMzNwMTogUENJRSBETUEgUlcgZXJyb3INCj4gKHN0YXR1cyA9IDB4NTAwMDQwMCkgWyA4
OTYwLjg2Njg3OV0gQVRMMUUgMDAwMDowNDowMC4wIHAzM3AxOiBOSUMgTGluayBpcyBVcA0KPiA8
MTAwIE1icHMgRnVsbCBEdXBsZXg+IFsgODk2MS4wOTUyNjZdIEFUTDFFIDAwMDA6MDQ6MDAuMCBw
MzNwMTogUENJRSBETUENCj4gUlcgZXJyb3IgKHN0YXR1cyA9IDB4NTAwMDQwMCkgWyA4OTYxLjEw
MDc5MV0gQVRMMUUgMDAwMDowNDowMC4wIHAzM3AxOiBOSUMNCj4gTGluayBpcyBVcCA8MTAwIE1i
cHMgRnVsbCBEdXBsZXg+DQo+IA0KSGFubmVzLCAgVGhhbmtzIGZvciB5b3VyIHRlc3RpbmcgIQ0K
DQogc2ltcGx5IHJldmlzaW5nIE1BWF9UWF9CVUZfTEVOIHRvIDB4NDAwMCB3aWxsIGNhdXNlIGlu
Y29ycmVjdCBUWCBjb25maWd1cmF0aW9uLi4uDQpJIG1lYW4geW91IGNhbiB0cnkgdG8gcHV0IGEg
Z3NvIHNpemUgbGltaXQgb2YgMHg0MDAwIChvciAweDUwMDApLi4uLg0KDQpUaGFua3MNClhpb25n
DQoNCg==
