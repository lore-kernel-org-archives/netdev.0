From: Johan Gunnarsson <johan.gunnarsson@axis.com>
Subject: RE: [PATCH] ethtool: don't overwrite useful bits in advertising
 bitfield
Date: Fri, 24 Aug 2012 11:50:14 +0200
Message-ID: <A612847CFE53224C91B23E3A5B48BAC7534E8D7DB1@xmail3.se.axis.com>
References: <1344953745-13208-1-git-send-email-johangu@axis.com>
	 <1345476178.2659.15.camel@bwh-desktop.uk.solarflarecom.com>
	 <A612847CFE53224C91B23E3A5B48BAC7534E8D76AD@xmail3.se.axis.com>
	 <1345561910.2659.45.camel@bwh-desktop.uk.solarflarecom.com>
	 <A612847CFE53224C91B23E3A5B48BAC7534E8D7809@xmail3.se.axis.com>
 <1345568582.2659.53.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mikael Starvik <starvik@axis.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.se.axis.com ([195.60.68.13]:54856 "EHLO ra.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758518Ab2HXJrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 05:47:37 -0400
In-Reply-To: <1345568582.2659.53.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQmVuIEh1dGNoaW5ncyBb
bWFpbHRvOmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+IFNlbnQ6IGRlbiAyMSBhdWd1c3Rp
IDIwMTIgMTk6MDMNCj4gVG86IEpvaGFuIEd1bm5hcnNzb24NCj4gQ2M6IG5ldGRldkB2Z2VyLmtl
cm5lbC5vcmc7IE1pa2FlbCBTdGFydmlrDQo+IFN1YmplY3Q6IFJFOiBbUEFUQ0hdIGV0aHRvb2w6
IGRvbid0IG92ZXJ3cml0ZSB1c2VmdWwgYml0cyBpbg0KPiBhZHZlcnRpc2luZyBiaXRmaWVsZA0K
PiANCj4gWy4uLl0NCj4gDQo+IDxsaW51eC9ldGh0b29sLmg+IG9yIGV0aHRvb2wtY29weS5oIGN1
cnJlbnRseSBkZWZpbmVzIHRoZSBtZWFuaW5ncyBvZg0KPiBiaXRzIDAtMjYgaW4gdGhlIHN1cHBv
cnRlZCBmaWVsZC4gIFlvdSBkZWZpbmUgQUxMX0FEVkVSVElTRURfTU9ERVMgdG8NCj4gaW5jbHVk
ZSBhbGwgb2YgdGhvc2UgdGhhdCBhcmUgbGluayBtb2Rlcy4gIEJ1dCBzb21lIHRpbWUgaW4gdGhl
IGZ1dHVyZSwNCj4gdGhlIHJlbWFpbmluZyBiaXRzIHdpbGwgYmUgYXNzaWduZWQgdG8gbmV3IGNh
cGFiaWxpdGllcy4NCj4gDQo+IElmIHRvZGF5J3MgZXRodG9vbCBpcyB1c2VkIHdpdGggYSBuZXdl
ciBkcml2ZXIgdGhhdCBzZXRzIGJpdCAyNyBpbiBpdHMNCj4gc3VwcG9ydGVkIGZpZWxkLCBldGh0
b29sIGNhbid0IHRlbGwgd2hldGhlciB0aGF0IHJlcHJlc2VudHMgYSBuZXcgbGluaw0KPiBtb2Rl
IHRoYXQgc2hvdWxkIGJlIGluY2x1ZGVkIGluIEFMTF9BRFZFUlRJU0VEX01PREVTLCBvciBzb21l
IG90aGVyDQo+IGtpbmQNCj4gb2YgY2FwYWJpbGl0eS4gIFNvIGl0IG1heSBub3QgYmUgYWJsZSB0
byBzZXQgdGhlIGRyaXZlcidzIGFkdmVydGlzaW5nDQo+IG1hc2sgY29ycmVjdGx5Lg0KDQpJIHNl
ZS4gVGhhbmtzLiBJJ2xsIHN1Ym1pdCBuZXcgdmVyc2lvbiBvZiB0aGUgcGF0Y2guDQoNCj4gDQo+
IEJlbi4NCj4gDQo+IC0tDQo+IEJlbiBIdXRjaGluZ3MsIFN0YWZmIEVuZ2luZWVyLCBTb2xhcmZs
YXJlDQo+IE5vdCBzcGVha2luZyBmb3IgbXkgZW1wbG95ZXI7IHRoYXQncyB0aGUgbWFya2V0aW5n
IGRlcGFydG1lbnQncyBqb2IuDQo+IFRoZXkgYXNrZWQgdXMgdG8gbm90ZSB0aGF0IFNvbGFyZmxh
cmUgcHJvZHVjdCBuYW1lcyBhcmUgdHJhZGVtYXJrZWQuDQoNCg==
