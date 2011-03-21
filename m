From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] netxen: fix LRO disable warning
Date: Mon, 21 Mar 2011 06:13:02 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8439@MNEXMB2.qlogic.org>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
 <1300704474.2884.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.186]:57394
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752628Ab1CULNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 07:13:13 -0400
In-Reply-To: <1300704474.2884.66.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBMZSBsdW5kaSAyMSBtYXJzIDIwMTEgw6AgMDM6MzcgLTA3MDAsIEFtaXQgS3VtYXIgU2FsZWNo
YSBhIMOpY3JpdCA6DQo+ID4gbmV0eGVuX25pY19zZXRfZmxhZ3MoKSByZWplY3RzIGRhdGEgaWYg
b3RoZXIgZmxhZyB0aGFuIEVUSF9GTEFHX0xSTw0KPiBpcyBzZXQuDQo+ID4gRHJpdmVyIGFsc28g
c3VwcG9ydHMgTkVUSUZfRl9IV19WTEFOX1RYLg0KPiA+IE5vdyBjb21wYXJlIGRhdGEgd2l0aCBl
dGh0b29sX29wX2dldF9mbGFncygpLCB0byBnZXQgYWxsIHN1cHBvcnRlZA0KPiBmZWF0dXJlcy4N
Cj4gPg0KPiA+IFJlcG9ydGVkLWJ5OiBKZXNwZXIgRGFuZ2FhcmQgQnJvdWVyIDxqZGJAY29teC5k
az4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBSYWplc2ggQm9ydW5kaWEgPHJhamVzaC5ib3J1bmRpYUBx
bG9naWMuY29tPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEFtaXQgS3VtYXIgU2FsZWNoYSA8YW1pdC5z
YWxlY2hhQHFsb2dpYy5jb20+DQo+ID4gLS0tDQo+DQo+IEhtbSwgaXQgd291bGQgYmUgcmVhbGx5
IG5pY2UgeW91IHByb3ZpZGUgbW9yZSBpbmZvcm1hdGlvbiBmb3Igc3RhYmxlDQo+IHRlYW1zLg0K
Pg0KPiBJZiBJIGFtIG5vdCBtaXN0YWtlbiwgYnVnIHdhcyBpbnRyb2R1Y2VkIGluIDIuNi4zNiA/
DQo+DQpObywgSXQgd2FzIGludHJvZHVjZWQgaW4gMi42LjM3LCB3aGVuIEVUSF9GTEFHX1RYVkxB
TiBhbmQgRVRIX0ZMQUdfUlhWTEFOIGludHJvZHVjZWQuDQpZZXMgaXQgc2hvdWxkIGFsc28gbWFr
ZSBpbnRvIDIuNi4zNy40IHN0YWJsZSBrZXJuZWwuDQoNCg0KVGhpcyBtZXNzYWdlIGFuZCBhbnkg
YXR0YWNoZWQgZG9jdW1lbnRzIGNvbnRhaW4gaW5mb3JtYXRpb24gZnJvbSBRTG9naWMgQ29ycG9y
YXRpb24gb3IgaXRzIHdob2xseS1vd25lZCBzdWJzaWRpYXJpZXMgdGhhdCBtYXkgYmUgY29uZmlk
ZW50aWFsLiBJZiB5b3UgYXJlIG5vdCB0aGUgaW50ZW5kZWQgcmVjaXBpZW50LCB5b3UgbWF5IG5v
dCByZWFkLCBjb3B5LCBkaXN0cmlidXRlLCBvciB1c2UgdGhpcyBpbmZvcm1hdGlvbi4gSWYgeW91
IGhhdmUgcmVjZWl2ZWQgdGhpcyB0cmFuc21pc3Npb24gaW4gZXJyb3IsIHBsZWFzZSBub3RpZnkg
dGhlIHNlbmRlciBpbW1lZGlhdGVseSBieSByZXBseSBlLW1haWwgYW5kIHRoZW4gZGVsZXRlIHRo
aXMgbWVzc2FnZS4NCg==

