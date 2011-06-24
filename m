From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Fri, 24 Jun 2011 01:53:35 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63F188EE61F@EXMAIL.ad.emulex.com>
References: <913f4373-e01f-4aa9-b8c7-d041d70f0945@exht1.ad.emulex.com>
 <1308911520.2228.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:23624 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751392Ab1FXIyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 04:54:07 -0400
In-Reply-To: <1308911520.2228.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86
ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj5TZW50OiBGcmlkYXksIEp1bmUgMjQsIDIwMTEgNDow
MiBQTQ0KPlRvOiBQZXJsYSwgU2F0aHlhDQo+Q2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj5T
dWJqZWN0OiBSZTogW1BBVENIIG5ldC1uZXh0LTIuNiAxLzNdIGJlMm5ldDogZml4IG5ldGRldl9z
dGF0c191cGRhdGUNCj4NCj5MZSB2ZW5kcmVkaSAyNCBqdWluIDIwMTEgw6AgMTM6NDMgKzA1MzAs
IFNhdGh5YSBQZXJsYSBhIMOpY3JpdCA6DQo+PiBuZXRkZXZfc3RhdHNfdXBkYXRlKCkgcmVzZXRz
IG5ldGRldi0+c3RhdHMgYW5kIHRoZW4gYWNjdW11bGF0ZXMgc3RhdHMgZnJvbQ0KPj4gdmFyaW91
cyByaW5ncy4gVGhpcyBpcyB3cm9uZyBhcyBzdGF0cyByZWFkZXJzIGNhbiBzb21ldGltZXMgY2F0
Y2ggemVybw0KPnZhbHVlcy4NCj4+IFVzZSB0ZW1wb3JhcnkgdmFyaWFibGVzIGluc3RlYWQgZm9y
IGFjY3VtdWxhdGluZyBwZXItcmluZyB2YWx1ZXMuDQo+Pg0KPj4gU2lnbmVkLW9mZi1ieTogU2F0
aHlhIFBlcmxhIDxzYXRoeWEucGVybGFAZW11bGV4LmNvbT4NCj4+IC0tLQ0KDQo+DQo+DQo+SG1t
LCBpc250IGl0IGEgcGF0Y2ggSSBwcm92aWRlZCAxMCBkYXlzIGFnbyA/DQo+DQo+SSBmaW5kIHZl
cnkgc3RyYW5nZSBzbyBmZXcgcGVvcGxlIGFyZSBhYmxlIHRvIHByb3Blcmx5IGF0dHJpYnV0ZSB3
b3JrDQo+dG9kYXkuLi4NCj4NCg0KWWVzLCB0aGlzIHBhdGNoIGlzIGluZGVlZCBiYXNlZCBvbiB5
b3VyIHN1Z2dlc3RlZC1maXggcGF0Y2ggbGFzdCB3ZWVrLg0KU29ycnksIGFyZSB5b3UgcmVmZXJy
aW5nIHRvIHRoZSBmYWN0IHRoYXQgSSBtaXNzZWQgYSAiU2lnbmVkLW9mZi1ieS1FcmljIj8NCklm
IHNvLCBteSBiYWQsIEknbGwgcmVzZW5kIHRoaXMgcGF0Y2ggd2l0aCB0aGF0IGxpbmUuLi4NCg==
