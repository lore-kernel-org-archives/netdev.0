From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 22:36:55 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC09604F3F@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
	 <1307655530.13329.49.camel@Joe-Laptop>
	 <A1F3067C9B68744AA19F6802BAB8FFDC09603E8F@TK5EX14MBXC227.redmond.corp.microsoft.com>
	 <20110609220701.GA24006@suse.de> <1307658497.18357.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailc.microsoft.com ([131.107.115.214]:47249 "EHLO
	smtp.microsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab1FIWg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 18:36:56 -0400
In-Reply-To: <1307658497.18357.6.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSm9lIFBlcmNoZXMgW21h
aWx0bzpqb2VAcGVyY2hlcy5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBKdW5lIDA5LCAyMDExIDY6
MjggUE0NCj4gVGhlIGxpbmUgY291bnQgb2YgdGhlIGZpbGVzIGFyZSBkaWZmZXJlbnQuDQo+IA0K
PiBJdCdzIG11Y2ggbW9yZSBkaWZmaWN1bHQgdG8gc2VlIHdoYXQgaWYgYW55dGhpbmcgaGFzIGNo
YW5nZWQNCj4gYmV0d2VlbiB0aGUgdHdvIHZlcnNpb25zLg0KDQpUaGUgb25seSBjaGFuZ2VzIGFy
ZSB0aGUgaW5jbHVkZSBmaWxlIG5hbWUsIGp1c3QgdG8gbWFrZSBpdCBjb21waWxlIGluIHRoZSBu
ZXQgZGlyLg0KQWZ0ZXIgYWxsIGNvZGUgcmV2aWV3IHN1Z2dlc3Rpb25zIGFyZSBkb25lIGludG8g
c3RhZ2luZy9odiwgSSB3aWxsIHN1Ym1pdCBhIHBhdGNoDQp3aXRoICItTSIgdG8gZ2V0IHRoZSBl
bnRpcmUgZHJpdmVyIG91dCBvZiBzdGFnaW5nIGFyZWEuDQoNCj4gdHJpdmlhOg0KPiANCj4gQWxs
IHRoZSBtZXNzYWdlIGxvZ2dpbmcgdXNlcyBvZiBkZXZfPGxldmVsPiBzaG91bGQgaGF2ZQ0KPiBh
IHRlcm1pbmF0aW5nIG5ld2xpbmUgIlxuIiBpbiBuZXR2c2MuYw0KPiANCj4gSW4gbmV0dnNjLmMg
ZGV2XzxsZXZlbD4gbWVzc2FnZXMgYXJlIHVzZWQuDQo+IEluIG5ldHZzY19kcnYuYyBuZXRkZXZf
PGxldmVsPiBtZXNzYWdlcyBhcmUgdXNlZC4NCj4gDQo+IGludCBuZXR2c2NfcmVjdl9jYWxsYmFj
ayhzdHJ1Y3QgaHZfZGV2aWNlICpkZXZpY2Vfb2JqLA0KPiAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgc3RydWN0IGh2X25ldHZzY19wYWNrZXQgKnBhY2tldCkNCj4gew0KPiAgICAgICAg
c3RydWN0IG5ldF9kZXZpY2UgKm5ldCA9IGRldl9nZXRfZHJ2ZGF0YSgmZGV2aWNlX29iai0+ZGV2
aWNlKTsNCj4gDQo+IE1heWJlIHVzZSB0aGUgbmV0ZGV2XzxsZXZlbD4gc3R5bGUgZXZlcnl3aGVy
ZSBwb3NzaWJsZT8NCg0KV2lsbCBkbyB0aGlzIGNoYW5nZS4NCg0KPiANCj4gSXQncyBvZGQgYW5k
IGEgYml0IHVnbHkgdG8gdXNlICNpbmNsdWRlICIuLi8uLi9zdGFnaW5nL2h5cGVydi5oIg0KPiAN
Cj4gTWF5YmUgYWRkIGFub3RoZXIgaW5jbHVkZSBwYXRoIHRvIHRoZSBNYWtlZmlsZSBhbmQganVz
dCB1c2UNCj4gI2luY2x1ZGUgImh5cGVydi5oIg0KPiB1bnRpbCBhbGwgb2YgdGhlIGh5cGVydiBm
aWxlcyBhcmUgbW92ZWQgb3V0IG9mIHN0YWdpbmc/DQoNCldpbGwgZG8uDQoNClRoYW5rcywNCi0g
SGFpeWFuZw0K
