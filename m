From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 1/1] net: Hyper-V: Deletion of an unnecessary check before
 the function call "vfree"
Date: Thu, 20 Nov 2014 18:58:22 +0000
Message-ID: <f8c8e81a61634b02b8e1f562588e1ced@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <546DF9D7.6080801@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-sn2-obe.ptr.o365filtering.com ([157.55.158.28]:22132 "EHLO
	na01-sn2-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757858AbaKTS6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 13:58:37 -0500
In-Reply-To: <546DF9D7.6080801@users.sourceforge.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU0YgTWFya3VzIEVsZnJp
bmcgW21haWx0bzplbGZyaW5nQHVzZXJzLnNvdXJjZWZvcmdlLm5ldF0NCj4gU2VudDogVGh1cnNk
YXksIE5vdmVtYmVyIDIwLCAyMDE0IDk6MjUgQU0NCj4gVG86IEhhaXlhbmcgWmhhbmc7IEtZIFNy
aW5pdmFzYW47IGRldmVsQGxpbnV4ZHJpdmVycHJvamVjdC5vcmc7DQo+IG5ldGRldkB2Z2VyLmtl
cm5lbC5vcmcNCj4gQ2M6IExLTUw7IGtlcm5lbC1qYW5pdG9yc0B2Z2VyLmtlcm5lbC5vcmc7IEp1
bGlhIExhd2FsbA0KPiBTdWJqZWN0OiBbUEFUQ0ggMS8xXSBuZXQ6IEh5cGVyLVY6IERlbGV0aW9u
IG9mIGFuIHVubmVjZXNzYXJ5IGNoZWNrDQo+IGJlZm9yZSB0aGUgZnVuY3Rpb24gY2FsbCAidmZy
ZWUiDQo+IA0KPiBGcm9tOiBNYXJrdXMgRWxmcmluZyA8ZWxmcmluZ0B1c2Vycy5zb3VyY2Vmb3Jn
ZS5uZXQ+DQo+IERhdGU6IFRodSwgMjAgTm92IDIwMTQgMTU6MTU6MjEgKzAxMDANCj4gDQo+IFRo
ZSB2ZnJlZSgpIGZ1bmN0aW9uIHBlcmZvcm1zIGFsc28gaW5wdXQgcGFyYW1ldGVyIHZhbGlkYXRp
b24uIFRodXMgdGhlDQo+IHRlc3QNCj4gYXJvdW5kIHRoZSBjYWxsIGlzIG5vdCBuZWVkZWQuDQo+
IA0KPiBUaGlzIGlzc3VlIHdhcyBkZXRlY3RlZCBieSB1c2luZyB0aGUgQ29jY2luZWxsZSBzb2Z0
d2FyZS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IE1hcmt1cyBFbGZyaW5nIDxlbGZyaW5nQHVzZXJz
LnNvdXJjZWZvcmdlLm5ldD4NCg0KU2lnbmVkLW9mZi1ieTogSGFpeWFuZyBaaGFuZyA8aGFpeWFu
Z3pAbWljcm9zb2Z0LmNvbT4NCg0KVGhhbmtzIQ0KDQo=
