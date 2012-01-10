From: Manfred Rudigier <manfred.rudigier@omicron.at>
Subject: RE: [PATCH v2] gianfar: Fix invalid TX frames returned on error
 queue when time stamping.
Date: Tue, 10 Jan 2012 10:05:15 +0100
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E3013A99172D@alice.at.omicron.at>
References: <1326120774-20647-1-git-send-email-manfred.rudigier@omicron.at>
 <1326121920.2407.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:41557 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755620Ab2AJJFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:05:38 -0500
In-Reply-To: <1326121920.2407.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZyBbbWFpbHRvOm5ldGRldi0NCm93bmVy
QHZnZXIua2VybmVsLm9yZ10gT24gQmVoYWxmIE9mIEVyaWMgRHVtYXpldA0KU2VudDogTW9uZGF5
LCBKYW51YXJ5IDA5LCAyMDEyIDE2OjEyDQoNCj4+ICsNCj4+ICsJCS8qIEhvbGQgc29jayByZWZl
cmVuY2UgZm9yIHByb2Nlc3NpbmcgVFggdGltZSBzdGFtcHMgKi8NCj4+ICsJCWlmICh1bmxpa2Vs
eShkb190c3RhbXApKSB7DQo+PiArCQkJc3RydWN0IHNvY2sgKnNrID0gc2tiLT5zazsNCj4NCj5O
b3QgY2xlYXIgdG8gbWUgd2h5IHNrX3JlZmNudCBjb3VsZCBiZSAwIGhlcmUNCg0KV2VsbCwgSSBo
YXZlIHRyaWVkIHRvIG1ha2UgYSBzaW1pbGFyIHNvbHV0aW9uIGFzIG91dGxpbmVkIGluIGNvbW1p
dCBkYTkyYjE5NGNjMzZiNWRjMWZiZDg1MjA2YWVlZmZkODBiZWUwYzM5Lg0KDQo+SSB3b3VsZCBy
YXRoZXIgZG8gc29tZXRoaW5nIGxpa2UgOg0KPg0KPmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9l
dGhlcm5ldC9mcmVlc2NhbGUvZ2lhbmZhci5jDQo+Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVl
c2NhbGUvZ2lhbmZhci5jDQo+aW5kZXggZTAxY2RhYS4uOGUwMDQ2MSAxMDA2NDQNCj4tLS0gYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2NhbGUvZ2lhbmZhci5jDQo+KysrIGIvZHJpdmVycy9u
ZXQvZXRoZXJuZXQvZnJlZXNjYWxlL2dpYW5mYXIuYw0KPkBAIC0yMDg2LDYgKzIwODYsOCBAQCBz
dGF0aWMgaW50IGdmYXJfc3RhcnRfeG1pdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QNCj5u
ZXRfZGV2aWNlICpkZXYpDQo+IAkJCWtmcmVlX3NrYihza2IpOw0KPiAJCQlyZXR1cm4gTkVUREVW
X1RYX09LOw0KPiAJCX0NCj4rCQlzd2FwKHNrYl9uZXctPnNrLCBza2ItPnNrKTsNCj4rCQlzd2Fw
KHNrYl9uZXctPmRlc3RydWN0b3IsIHNrYi0+ZGVzdHJ1Y3Rvcik7DQo+IAkJa2ZyZWVfc2tiKHNr
Yik7DQo+IAkJc2tiID0gc2tiX25ldzsNCj4gCX0NCg0KSSBndWVzcyB0aGlzIHNob3VsZCBhbHNv
IHdvcmssIHNvIEkgd2lsbCBjb21lIHVwIHdpdGggYSBuZXcgdmVyc2lvbi4NCg==
