From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow_dissector: Pre-initialize ip_proto in
 __skb_flow_dissect()
Date: Thu, 25 Jun 2015 06:33:31 -0700 (PDT)
Message-ID: <20150625.063331.1437042913073267200.davem@davemloft.net>
References: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: tom@herbertland.com, jiri@resnulli.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbFYNVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:21:38 -0400
In-Reply-To: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFRo
dSwgMjUgSnVuIDIwMTUgMTU6MTA6MzIgKzAyMDANCg0KPiBuZXQvY29yZS9mbG93X2Rpc3NlY3Rv
ci5jOiBJbiBmdW5jdGlvbiChX19za2JfZmxvd19kaXNzZWN0ojoNCj4gbmV0L2NvcmUvZmxvd19k
aXNzZWN0b3IuYzoxMzI6IHdhcm5pbmc6IKFpcF9wcm90b6IgbWF5IGJlIHVzZWQgdW5pbml0aWFs
aXplZCBpbiB0aGlzIGZ1bmN0aW9uDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0ZXJo
b2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KPiAtLS0NCj4gVGhpcyBtYXkgYmUgYSBmYWxz
ZSBwb3NpdGl2ZSwgYnV0IHRoZSBzdGF0ZSBtYWNoaW5lIGluDQo+IF9fc2tiX2Zsb3dfZGlzc2Vj
dCgpIGlzIGEgYml0IGhhcmQgdG8gZm9sbG93Lg0KPiBBcyBJIGJlbGlldmUgaXQgaXMgY29udHJv
bGxlZCBieSBhIHBhY2tldCByZWNlaXZlZCBmcm9tIHRoZSBuZXR3b3JrLCB0aGUNCj4gb25seSBz
YWZlIHRoaW5nIHRvIGRvIGlzIHRvIHByZS1pbml0aWFsaXplIGlwX3Byb3RvLg0KDQpBY3R1YWxs
eSBJIHRoaW5rIHRoaXMgaXMgYSByZWFsIGJ1ZywgYmVjYXVzZSBmb3IgdGhlIEVUSF9QX01QTFNf
KiBjYXNlcyBJIGNhbm5vdA0Kc2VlIHdoYXQgd2lsbCBhbHdheXMgc2V0IGlwX3Byb3RvIGJlZm9y
ZSBpdCBnZXRzIHVzZWQgYXMgYW4gaW5wdXQuDQo=
