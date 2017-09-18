From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net_sched: use explicit size of struct tcmsg, remove
 need to declare tcm
Date: Mon, 18 Sep 2017 12:18:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD007891E@AcuExch.aculab.com>
References: <20170918114038.29741-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Colin King' <colin.king@canonical.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170918114038.29741-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQ29saW4gS2luZw0KPiBTZW50OiAxOCBTZXB0ZW1iZXIgMjAxNyAxMjo0MQ0KPiBQb2lu
dGVyIHRjbSBpcyBiZWluZyBpbml0aWFsaXplZCBhbmQgaXMgbmV2ZXIgcmVhZCwgaXQgaXMgb25s
eSBiZWluZyB1c2VkDQo+IHRvIGRldGVybWluZSB0aGUgc2l6ZSBvZiBzdHJ1Y3QgdGNtc2cuICBD
bGVhbiB0aGlzIHVwIGJ5IHJlbW92aW5nDQo+IHZhcmlhYmxlIHRjbSBhbmQgZXhwbGljaXRseSB1
c2luZyB0aGUgc2l6ZW9mIHN0cnVjdCB0Y21zZyByYXRoZXIgdGhhbiAqdGNtLg0KPiBDbGVhbnMg
dXAgY2xhbmcgd2FybmluZzoNCj4gDQo+IHdhcm5pbmc6IFZhbHVlIHN0b3JlZCB0byAndGNtJyBk
dXJpbmcgaXRzIGluaXRpYWxpemF0aW9uIGlzIG5ldmVyIHJlYWQNCj4gDQo+IFNpZ25lZC1vZmYt
Ynk6IENvbGluIElhbiBLaW5nIDxjb2xpbi5raW5nQGNhbm9uaWNhbC5jb20+DQo+IC0tLQ0KPiAg
bmV0L3NjaGVkL3NjaF9hcGkuYyB8IDMgKy0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRp
b24oKyksIDIgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvbmV0L3NjaGVkL3NjaF9h
cGkuYyBiL25ldC9zY2hlZC9zY2hfYXBpLmMNCj4gaW5kZXggYzZkZWI3NGUzZDJmLi5hYTgyMTE2
ZWQxMGMgMTAwNjQ0DQo+IC0tLSBhL25ldC9zY2hlZC9zY2hfYXBpLmMNCj4gKysrIGIvbmV0L3Nj
aGVkL3NjaF9hcGkuYw0KPiBAQCAtMTUwMCw3ICsxNTAwLDYgQEAgc3RhdGljIGludCB0Y19kdW1w
X3FkaXNjKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRsaW5rX2NhbGxiYWNrICpjYikN
Cj4gIAlpbnQgc19pZHgsIHNfcV9pZHg7DQo+ICAJc3RydWN0IG5ldF9kZXZpY2UgKmRldjsNCj4g
IAljb25zdCBzdHJ1Y3Qgbmxtc2doZHIgKm5saCA9IGNiLT5ubGg7DQo+IC0Jc3RydWN0IHRjbXNn
ICp0Y20gPSBubG1zZ19kYXRhKG5saCk7DQo+ICAJc3RydWN0IG5sYXR0ciAqdGNhW1RDQV9NQVgg
KyAxXTsNCj4gIAlpbnQgZXJyOw0KPiANCj4gQEAgLTE1MTAsNyArMTUwOSw3IEBAIHN0YXRpYyBp
bnQgdGNfZHVtcF9xZGlzYyhzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgbmV0bGlua19jYWxs
YmFjayAqY2IpDQo+ICAJaWR4ID0gMDsNCj4gIAlBU1NFUlRfUlROTCgpOw0KPiANCj4gLQllcnIg
PSBubG1zZ19wYXJzZShubGgsIHNpemVvZigqdGNtKSwgdGNhLCBUQ0FfTUFYLCBOVUxMLCBOVUxM
KTsNCj4gKwllcnIgPSBubG1zZ19wYXJzZShubGgsIHNpemVvZihzdHJ1Y3QgdGNtc2cpLCB0Y2Es
IFRDQV9NQVgsIE5VTEwsIE5VTEwpOw0KDQpXb3VsZCBzaXplb2YoKm5sbXNnX2RhdGEobmxoKSkg
YmUgY2xlYW5lcj8/DQoNCglEYXZpZA0KDQo=
