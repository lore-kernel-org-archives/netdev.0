From: nhorman@tuxdriver.com
Subject: Re: [PATCH] sctp: properly latch and use autoclose value from sock
 to association
Date: Mon, 09 Dec 2013 22:03:41 -0500
Message-ID: <E1VqDbx-0006lk-Ka@smtp.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, wangweidong1@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43459 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3LJDEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:04:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T2sgSSdsbCByZXBvc3Qgd2hlbiBJIGdldCBvdXQgb2YgY2xhc3MgdG9tb3Jyb3cgZXZlbmluZwoK
TmVpbAoKT24gRGVjIDksIDIwMTMgODozMiBQTSwgRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxv
ZnQubmV0PiB3cm90ZToKPgo+IEZyb206IE5laWwgSG9ybWFuIDxuaG9ybWFuQHR1eGRyaXZlci5j
b20+IAo+IERhdGU6IEZyaSzCoCA2IERlYyAyMDEzIDEwOjI5OjE1IC0wNTAwIAo+Cj4gPiBAQCAt
MjIwNSw2ICsyMjA2LDEyIEBAIHN0YXRpYyBpbnQgc2N0cF9zZXRzb2Nrb3B0X2F1dG9jbG9zZShz
dHJ1Y3Qgc29jayAqc2ssIGNoYXIgX191c2VyICpvcHR2YWwsIAo+ID7CoCBpZiAoY29weV9mcm9t
X3VzZXIoJnNwLT5hdXRvY2xvc2UsIG9wdHZhbCwgb3B0bGVuKSkgCj4gPsKgIHJldHVybiAtRUZB
VUxUOyAKPiA+wqAgCj4gPiArIGlmIChzcC0+YXV0b2Nsb3NlID4gbmV0LT5zY3RwLm1heF9hdXRv
Y2xvc2UpIHsgCj4gPiArIHByX3dhcm4oIkNhcHBpbmcgYXV0b2Nsb3NlIHZhbHVlICVkIHRvIGRl
ZmluZWQgbWF4aW11bSBvZiAlbHVcbiIsIAo+ID4gKyBzcC0+YXV0b2Nsb3NlLCBuZXQtPnNjdHAu
bWF4X2F1dG9jbG9zZSk7IAo+ID4gKyBzcC0+YXV0b2Nsb3NlID0gbmV0LT5zY3RwLm1heF9hdXRv
Y2xvc2U7IAo+ID4gKyB9IAo+Cj4gUGxlYXNlIGRvbid0IGFkZCB0aGlzIHdhcm5pbmcuIAo+Cj4g
SWYgd2UgYWxyZWFkeSBkbyB0aGlzIGZvciBjZXJ0YWluIHNldHNvY2tvcHQgY2FsbHMgaW4gU0NU
UCwgdGhhdCBqdXN0IAo+IG1lYW5zIHdlIGhhdmUgYnVncyB0byBmaXguIAo+Cg==
