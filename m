From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH NEXT 3/5] qlcnic: vlan lro support
Date: Fri, 17 Sep 2010 02:10:32 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86F8005A@MNEXMB2.qlogic.org>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-4-git-send-email-amit.salecha@qlogic.com>
 <1284643638.3352.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:9740 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab0IQHKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 03:10:37 -0400
In-Reply-To: <1284643638.3352.30.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRXJpYyBEdW1hemV0IFtt
YWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIFNlcHRlbWJl
ciAxNiwgMjAxMCA2OjU3IFBNDQo+IFRvOiBBbWl0IFNhbGVjaGENCj4gQ2M6IGRhdmVtQGRhdmVt
bG9mdC5uZXQ7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IEFtZWVuIFJhaG1hbjsgQW5pcmJhbg0K
PiBDaGFrcmFib3J0eQ0KPiBTdWJqZWN0OiBSZTogW1BBVENIIE5FWFQgMy81XSBxbGNuaWM6IHZs
YW4gbHJvIHN1cHBvcnQNCj4gDQo+IExlIGpldWRpIDE2IHNlcHRlbWJyZSAyMDEwIMOgIDA2OjE0
IC0wNzAwLCBBbWl0IEt1bWFyIFNhbGVjaGEgYSDDqWNyaXQgOg0KPiA+IExSTyArIEdSTyArIHZs
YW4gcnggYWNjbGVyYXRpb24gc3VwcG9ydCwgcGVyZm9ybWFuY2UgaW5jcmVhc2VzDQo+ID4gYXJv
dW5kIDIwJSBhbmQgY3B1IHV0aWxpemF0aW9uIHJlZHVjZXMgYXJvdW5kIDcwJSBvbiB2bGFuIGlu
dGVyZmFjZS4NCj4gDQo+IEludGVyZXN0aW5nLiBXaGF0IGlzIHRoZSB3b3JrbG9hZCB0aGF0IGRl
bW9uc3RyYXRlcyBzdWNoIGdhaW5zID8NCj4gDQo+IA0KSnVzdCB0byBkZW1vbnN0cmF0ZSBkZWNy
ZWFzZSBpbiBjcHUgdXRpbGl6YXRpb24gZnVydGhlcjoNCkkgaGF2ZSB0YWtlbiBudW1iZXJzIHdp
dGggdmFyaW91cyBsb2FkLiBJIHVzZWQgaXBlcmYgYXBwbGljYXRpb24gdG8gcnVuIHRjcCB0cmFm
ZmljIG9uIHZsYW4gaW50ZXJmYWNlLg0KDQpOdW1iZXIgb2YgVENQIGNvbm5lY3Rpb24JIENwdSAg
JWlkbGUJCUNwdSAlaWRsZQ0KCQkJCQkgKHcvbyBwYXRjaCkJKHdpdGggcGF0Y2gpDQoNCgk4CQkJ
CTM0LjE0CQkJNjMuMDENCgkxNgkJCQkzNC4zNgkJCTYyLjM4DQoJMzIJCQkJMzMuODYJCQk2Mi4x
OA0KCTY0CQkJCTMwLjYyCQkJNjEuOTQNCgkxMjgJCQkJMjkuMzMJCQk2MS4xMw0KCTI1NgkJCQky
Ny43OQkJCTU5LjQ2DQoJNTEyCQkJCTI1LjMzCQkJNTkuMzgNCg0KVGhlcmUgaXMgYXJvdW5kIDgw
LTkwJSBvZiByZWR1Y3Rpb24gaW4gY3B1IHV0aWxpemF0aW9uLg0KDQotQW1pdA0KDQoNCg==
