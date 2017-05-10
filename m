From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/4] hamradio: Combine two seq_printf() calls into one
 in yam_seq_show()
Date: Wed, 10 May 2017 08:48:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE852F@AcuExch.aculab.com>
References: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
 <c2866b46-28c9-f17f-dce7-96425a17a43a@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: 'SF Markus Elfring' <elfring@users.sourceforge.net>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c2866b46-28c9-f17f-dce7-96425a17a43a@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogU0YgTWFya3VzIEVsZnJpbmcNCj4gU2VudDogMDkgTWF5IDIwMTcgMTU6MjINCj4gQSBi
aXQgb2YgZGF0YSB3YXMgcHV0IGludG8gYSBzZXF1ZW5jZSBieSB0d28gc2VwYXJhdGUgZnVuY3Rp
b24gY2FsbHMuDQo+IFByaW50IHRoZSBzYW1lIGRhdGEgYnkgYSBzaW5nbGUgZnVuY3Rpb24gY2Fs
bCBpbnN0ZWFkLg0KPiANCj4gVGhpcyBpc3N1ZSB3YXMgZGV0ZWN0ZWQgYnkgdXNpbmcgdGhlIENv
Y2NpbmVsbGUgc29mdHdhcmUuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBNYXJrdXMgRWxmcmluZyA8
ZWxmcmluZ0B1c2Vycy5zb3VyY2Vmb3JnZS5uZXQ+DQo+IC0tLQ0KPiAgZHJpdmVycy9uZXQvaGFt
cmFkaW8veWFtLmMgfCAzICstLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAy
IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2hhbXJhZGlvL3lh
bS5jIGIvZHJpdmVycy9uZXQvaGFtcmFkaW8veWFtLmMNCj4gaW5kZXggYjY4OTFhZGExZDdiLi41
NDJmMWU1MTFkZjEgMTAwNjQ0DQo+IC0tLSBhL2RyaXZlcnMvbmV0L2hhbXJhZGlvL3lhbS5jDQo+
ICsrKyBiL2RyaXZlcnMvbmV0L2hhbXJhZGlvL3lhbS5jDQo+IEBAIC04MzAsOCArODMwLDcgQEAg
c3RhdGljIGludCB5YW1fc2VxX3Nob3coc3RydWN0IHNlcV9maWxlICpzZXEsIHZvaWQgKnYpDQo+
ICAJc2VxX3ByaW50ZihzZXEsICIgIFJ4RnJhbWVzICVsdVxuIiwgZGV2LT5zdGF0cy5yeF9wYWNr
ZXRzKTsNCj4gIAlzZXFfcHJpbnRmKHNlcSwgIiAgVHhJbnQgICAgJXVcbiIsIHlwLT5uYl9tZGlu
dCk7DQo+ICAJc2VxX3ByaW50ZihzZXEsICIgIFJ4SW50ICAgICV1XG4iLCB5cC0+bmJfcnhpbnQp
Ow0KPiAtCXNlcV9wcmludGYoc2VxLCAiICBSeE92ZXIgICAlbHVcbiIsIGRldi0+c3RhdHMucnhf
Zmlmb19lcnJvcnMpOw0KPiAtCXNlcV9wcmludGYoc2VxLCAiXG4iKTsNCj4gKwlzZXFfcHJpbnRm
KHNlcSwgIiAgUnhPdmVyICAgJWx1XG5cbiIsIGRldi0+c3RhdHMucnhfZmlmb19lcnJvcnMpOw0K
PiAgCXJldHVybiAwOw0KDQpUaGUgY29kZSB3YXMgY29uc2lzdGVudGx5IChhbmQgcHJvYmFibHkg
ZGVsaWJlcmF0ZWx5KSB1c2luZyBvbmUgc2VxX3ByaW50ZigpDQpjYWxsIGZvciBlYWNoIGxpbmUg
c28gdGhhdCB0aGUgc291cmNlIGxvb2tzICdhIGJpdCBsaWtlJyB0aGUgb3V0cHV0Lg0KDQpUaGVz
ZSBjaGFuZ2VzIGFyZSBhbGwgc3R1cGlkLg0KDQoJRGF2aWQNCg0K
