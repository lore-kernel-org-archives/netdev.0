From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 12:41:03 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com> <20130528.233647.1209227470109213894.davem@davemloft.net> <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com> <20130529194438.GY3333@ritirata.org> <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>, <amwang@redhat.com>,
	<netdev@vger.kernel.org>, <horms@verge.net.au>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Antonio Quartulli" <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49686 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934952Ab3E3Llt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 07:41:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12478-09 for <netdev@vger.kernel.org>;
 Thu, 30 May 2013 12:41:46 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gPiBJIHdhbnQgdG8gdXNlIHNvbWV0aGluZyB0aGF0IHdpbGwgZWl0aGVyIGJyZWFrIHRo
ZSBidWlsZCBvcg0KPiA+ID4gPiBhdXRvbWF0aWNhbGx5IHdvcmsgaWYgdGhlIHR5cGUgY2hhbmdl
cyBhZ2Fpbi4NCj4gPiA+ID4NCj4gPiA+ID4gU28gc29tZXRoaW5nIGxpa2UgIlggPSAodHlwZW9m
KFgpKSB+MFU7Ii4NCj4gPiA+DQo+ID4gPiBJIHRoaW5rIHlvdSBtZWFuIH4odHlwZW9mKFgpKTAu
DQo+ID4NCj4gPiBBbSBJIHdyb25nIG9yIHlvdSBzaG91bGQgY2FzdCB0aGUgdmFsdWUgb25jZSBh
Z2FpbiwgbGlrZSB0aGlzOg0KPiA+DQo+ID4gKCh0eXBlb2YoWCkpfih0eXBlb2YoWCkpMCkNCj4g
Pg0KPiA+IGJlY2F1c2UgdGhlIH4gb3BlcmF0b3Igd2lsbCBpbXBsaWNpdGx5IGNhc3QgdGhlIGFy
Z3VtZW50IHRvIGludCAoaWYgSSByZW1lbWJlcg0KPiA+IGNvcnJlY3RseSkuDQo+IA0KPiBJdCB3
aWxsIHByb21vdGUgdG8gYXQgbGVhc3QgaW50LCBidXQgdGhhdCBzdGlsbCByZXN1bHRzIGluIHRo
ZSByaWdodA0KPiB2YWx1ZSBhbmQgZG9lc24ndCBwcm92b2tlIGEgd2FybmluZy4gIFRyeSB0aGlz
IHRlc3QgKHdpdGggLVdhbGwNCj4gLVdleHRyYSk6DQo+IA0KPiAjaW5jbHVkZSA8c3RkaW8uaD4N
Cj4gDQo+ICNkZWZpbmUgQUxMX09ORVModikgKH4odHlwZW9mKHYpKTApDQo+IC8qICNkZWZpbmUg
QUxMX09ORVModikgKHR5cGVvZih2KSl+MFUpICovDQo+IA0KPiBpbnQgbWFpbih2b2lkKQ0KPiB7
DQo+ICAgICBjaGFyIGEgPSBBTExfT05FUyhhKTsNCj4gICAgIHVuc2lnbmVkIGNoYXIgYiA9IEFM
TF9PTkVTKGIpOw0KPiAgICAgc2hvcnQgYyA9IEFMTF9PTkVTKGMpOw0KPiAgICAgdW5zaWduZWQg
c2hvcnQgZCA9IEFMTF9PTkVTKGQpOw0KPiAgICAgaW50IGUgPSBBTExfT05FUyhlKTsNCj4gICAg
IHVuc2lnbmVkIGludCBmID0gQUxMX09ORVMoZik7DQo+ICAgICBsb25nIGcgPSBBTExfT05FUyhn
KTsNCj4gICAgIHVuc2lnbmVkIGxvbmcgaCA9IEFMTF9PTkVTKGgpOw0KPiAgICAgbG9uZyBsb25n
IGkgPSBBTExfT05FUyhpKTsNCj4gICAgIHVuc2lnbmVkIGxvbmcgbG9uZyBqID0gQUxMX09ORVMo
aik7DQo+IA0KPiAgICAgcHJpbnRmKCIlaGh4ICVoaHggJWh4ICVoeCAleCAleCAlbHggJWx4ICVs
bHggJWxseFxuIiwNCj4gCSAgIGEsIGIsIGMsIGQsIGUsIGYsIGcsIGgsIGksIGopOw0KPiAgICAg
cmV0dXJuIDA7DQo+IH0NCg0KVGhlIHByaW50ZiBmb3JtYXQgaXMgbWFza2luZyB0aGUgaGlnaCBi
aXRzIGZvciB5b3UuDQpJZiB5b3UgY2hhbmdlIHRvOg0KCXByaW50ZigiJXggJXggJXggJXggJXgg
JXggJWx4ICVseCAlbGx4ICVsbHhcbiIsIC4uLikNCnlvdSBnZXQgZGlmZmVyZW50IHZhbHVlcy4N
ClRvIGdldCB0aGUgJ2V4cGVjdGVkJyB2YWx1ZXMgeW91IG5lZWQgY2FzdHMgYm90aCBzaWRlcyBv
ZiB0aGUgfg0KDQoJRGF2aWQNCg0K
