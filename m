From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 2/2] r8152: rx descriptor check
Date: Mon, 14 Nov 2016 07:23:51 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20104EBCC@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161113.123954.2134945576362221851.davem@davemloft.net>
 <cd36fce8-2f17-debd-d514-e3cbe7ed3762@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:41642 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcKNHYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 02:24:09 -0500
In-Reply-To: <cd36fce8-2f17-debd-d514-e3cbe7ed3762@pobox.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TWFyayBMb3JkIFttYWlsdG86bWxvcmRAcG9ib3guY29tXQ0KPiBTZW50OiBNb25kYXksIE5vdmVt
YmVyIDE0LCAyMDE2IDQ6MzQgQU0NClsuLi5dDQo+IFBlcmhhcHMgdGhlIGRyaXZlcg0KPiBpcyBz
b21laG93IGFjY2Vzc2luZyB0aGUgYnVmZmVyIHNwYWNlIGFnYWluIGFmdGVyIGRvaW5nIHVzYl9z
dWJtaXRfdXJiKCk/DQo+IFRoYXQgd291bGQgY2VydGFpbmx5IHByb2R1Y2UgdGhpcyBraW5kIG9m
IGJlaGF2aW91ci4NCg0KSSBkb24ndCB0aGluayBzby4gRmlyc3QsIHRoZSBkcml2ZXIgb25seSBy
ZWFkIHRoZSByZWNlaXZlZCBidWZmZXIuDQpUaGF0IGlzLCB0aGUgZHJpdmVyIHdvdWxkIG5vdCBj
aGFuZ2UgKG9yIHdyaXRlKSB0aGUgZGF0YS4gU2Vjb25kLA0KVGhlIGRyaXZlciB3b3VsZCBsb3Nl
IHRoZSBwb2ludCBhZGRyZXNzIG9mIHRoZSByZWNlaXZlZCBidWZmZXINCmFmdGVyIHN1Ym1pdHRp
bmcgdGhlIHVyYiB0byB0aGUgVVNCIGhvc3QgY29udHJvbGxlciwgdW50aWwgdGhlDQp0cmFuc2Zl
ciBpcyBjb21wbGV0ZWQgYnkgdGhlIFVTQiBob3N0IGNvbnRyb2xsZXIuIFRoYXQgaXMsIHRoZQ0K
ZHJpdmVyIGRvZXNuJ3QgaG93IHRvIGFjY2VzcyB0aGUgYnVmZmVyIGFmdGVyIGNhbGxpbmcgdXNi
X3N1Ym1pdF91cmIoKS4NCg0KQmVzdCBSZWdhcmRzLA0KSGF5ZXMNCg0K
