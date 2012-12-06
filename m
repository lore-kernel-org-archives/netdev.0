From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [net-next 6/8] bna: Add Stats Clear Counter
Date: Thu, 6 Dec 2012 15:23:38 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B5B0B9CB7A@HQ1-EXCH01.corp.brocade.com>
References: <1354748470-26293-1-git-send-email-rmody@brocade.com>
	 <1354748470-26293-7-git-send-email-rmody@brocade.com>
	 <1354760382.17107.140.camel@deadeye.wl.decadent.org.uk>
	 <E5313AF6F2BFD14293E5FD0F94750F86B5B0B9CAF5@HQ1-EXCH01.corp.brocade.com>
 <1354827275.2828.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:40431 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750979Ab2LFXXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:23:46 -0500
In-Reply-To: <1354827275.2828.37.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PkZyb206IEJlbiBIdXRjaGluZ3MgW21haWx0bzpiaHV0Y2hpbmdzQHNvbGFyZmxhcmUuY29tXQ0K
PlNlbnQ6IFRodXJzZGF5LCBEZWNlbWJlciAwNiwgMjAxMiAxMjo1NSBQTQ0KPg0KPk9uIFRodSwg
MjAxMi0xMi0wNiBhdCAxMjozNCAtMDgwMCwgUmFzZXNoIE1vZHkgd3JvdGU6DQo+PiA+RnJvbTog
QmVuIEh1dGNoaW5ncyBbbWFpbHRvOmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+PiA+U2Vu
dDogV2VkbmVzZGF5LCBEZWNlbWJlciAwNSwgMjAxMiA2OjIwIFBNDQo+PiA+U3ViamVjdDogUmU6
IFtuZXQtbmV4dCA2LzhdIGJuYTogQWRkIFN0YXRzIENsZWFyIENvdW50ZXINCj4+ID4NCj4+ID5P
biBXZWQsIDIwMTItMTItMDUgYXQgMTU6MDEgLTA4MDAsIFJhc2VzaCBNb2R5IHdyb3RlOg0KPj4g
Pj4gQWRkZWQgU3RhdHMgY2xlYXIgY291bnRlciB0byB0aGUgYmZpX2VuZXRfc3RhdHNfbWFjIHN0
cnVjdHVyZSBhbmQNCj4+ID4+IGV0aHRvb2wgc3RhdHMNCj4+ID4+DQo+PiA+PiBTaWduZWQtb2Zm
LWJ5OiBSYXNlc2ggTW9keSA8cm1vZHlAYnJvY2FkZS5jb20+DQo+PiA+DQo+PiA+U2luY2UgdGhp
cyBzdHJ1Y3R1cmUgYXBwZWFycyB0byBiZSBwYXJ0IG9mIHRoZSBmaXJtd2FyZSBpbnRlcmZhY2Us
DQo+PiA+eW91IHNob3VsZCBjb21iaW5lIHRoaXMgKGFuZCBhbnkgb3RoZXIgaW50ZXJmYWNlIGNo
YW5nZXMpIHdpdGggdGhlDQo+PiA+Y2hhbmdlIHRvIHRoZSByZXF1ZXN0ZWQgZmlybXdhcmUgdmVy
c2lvbiAoNy84KS4NCj4+DQo+PiBCZW4sDQo+Pg0KPj4gVGhhbmtzIGZvciB0aGUgZmVlZGJhY2su
IFllcywgYmZpX2VuZXRfc3RhdHNfbWFjIGlzIGEgcGFydCBvZiBmaXJtd2FyZQ0KPj4gaW50ZXJm
YWNlIHVwZGF0ZS4NCj4+DQo+PiBJbiBmdXR1cmUgc3VibWlzc2lvbiwgSSB3aWxsIHBsYW4gdG8g
dGFrZSBjYXJlIG9mIGNvbWJpbmluZyBzdWNoDQo+PiBmaXJtd2FyZSBpbnRlcmZhY2UgdXBkYXRl
cy9jaGFuZ2VzIGFuZCB0aGUgZmlybXdhcmUgcmVxdWVzdCB2ZXJzaW9uDQo+PiBjaGFuZ2UgaW50
byBzaW5nbGUgcGF0Y2guIFBsZWFzZSBsZXQgbWUga25vdyBpZiB5b3UgdGhpbmsgaXQgaXMNCj4+
IHJlcXVpcmVkIGZvciB0aGlzIHBhdGNoIHNldC4NCj4NCj5UaGF0J3Mgbm90IG15IGRlY2lzaW9u
Lg0KDQpJIGhhdmUgcmVzdWJtaXR0ZWQgdGhlIHBhdGNoIHNldCB0byBhZGRyZXNzIHlvdSBmZWVk
YmFjay4NCg0KVGhhbmtzLA0KUmFzZXNoDQo=
