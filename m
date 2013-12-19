From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add support for Virtual Receive Side
 Scaling (vRSS)
Date: Thu, 19 Dec 2013 23:15:25 +0000
Message-ID: <3eb3eb6885704b6098c39fad1fdfc443@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
References: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
	<1387475178.1876.29.camel@bwh-desktop.uk.level5networks.com>
	<ff7f7541d0164d408b3a4278569c593a@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<52B33EC1.5040901@redhat.com>
	<6ee28c6a94e74c958ee96c3547741fb9@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	<CA+mtBx-BBBQjVTOrnaow=GNc7VM5D2Zj8xr=fPM4b4f_xT7qkQ@mail.gmail.com>
	<05be4f23ff784e56b710dd02eb88358a@DFM-DB3MBX15-08.exchange.corp.microsoft.com>
 <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+mtBx_SSPd6s5519dWCyPGmFvO=kE+Fh3ZQ9w9oo=pJraRAFQ@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBUb20gSGVyYmVydCBbbWFpbHRv
OnRoZXJiZXJ0QGdvb2dsZS5jb21dDQo+IFNlbnQ6IFRodXJzZGF5LCBEZWNlbWJlciAxOSwgMjAx
MyA0OjQzIFBNDQo+IFRvOiBIYWl5YW5nIFpoYW5nDQo+IENjOiBEYW5pZWwgQm9ya21hbm47IEJl
biBIdXRjaGluZ3M7IGRhdmVtQGRhdmVtbG9mdC5uZXQ7DQo+IG5ldGRldkB2Z2VyLmtlcm5lbC5v
cmc7IEtZIFNyaW5pdmFzYW47IG9sYWZAYWVwZmxlLmRlOw0KPiBqYXNvd2FuZ0ByZWRoYXQuY29t
OyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBkcml2ZXJkZXYtDQo+IGRldmVsQGxpbnV4
ZHJpdmVycHJvamVjdC5vcmcNCj4gU3ViamVjdDogUmU6IFtQQVRDSCBuZXQtbmV4dF0gaHlwZXJ2
OiBBZGQgc3VwcG9ydCBmb3IgVmlydHVhbCBSZWNlaXZlIFNpZGUNCj4gU2NhbGluZyAodlJTUykN
Cj4gDQo+IFBhdGNoIGlzIGJlbG93LiBUaGlzIHZlcnNpb24gZGlkIG1vc3QgcHJlLWNvbXB1dGF0
aW9uIG9mIHRoZSB2YXJpYW50cyBJIGJ1aWx0LA0KPiBidXQgcmVzdWx0cyBpbiBsYXJnZXN0IHRh
YmxlICg0MCoyNTYqNCBieXRlcyksIFRoaXMgZ2l2ZXMgcGVyZm9ybWFuY2Ugcm91Z2hseQ0KPiBj
b21wYXJhYmxlIHdpdGggamhhc2ggKHJvdWdobHkgc2FtZSBhcyBqaGFzaCBmb3IgSVB2NCwgYWJv
dXQgMzAlIG1vcmUNCj4gY3ljbGVzIGZvciBJUHY2KS4gSSBoYXZlIHRoZSBzaW1wbGVyIGxlc3Mg
bWVtb3J5IGludGVuc2l2ZSB2ZXJzaW9ucyBhbHNvIGlmDQo+IHlvdSdyZSBpbnRlcmVzdGVkLCB0
aGVzZSBhcmUgMTB4IHdvcnNlIGN5Y2xlcyBzbyBJIHdvdWxkbid0IHdhbnQgdGhvc2UgaW4NCj4g
Y3JpdGljYWwgcGF0aC4NCj4gLS0tLQ0KDQpUaGFuayB5b3UgZm9yIHRoZSBjb2RlLiBXZSBsaWtl
IHRoZSBmYXN0IGltcGxlbWVudGF0aW9uIGV2ZW4gaXQgdXNlcyBhIGJpdCBtb3JlDQptZW1vcnku
IEFyZSB5b3UgZ29pbmcgdG8gYWRkcmVzcyB0aGUgY29tbWVudHMgYW5kIHJlLXN1Ym1pdCB0aGUg
Y29kZSBzb29uPw0KDQpUaGFua3MsDQotIEhhaXlhbmcNCg==
