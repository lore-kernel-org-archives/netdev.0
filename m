From: CLOSE Dave <Dave.Close@us.thalesgroup.com>
Subject: Trying to ping from a subinterface.
Date: Mon, 2 Jun 2014 13:47:06 -0700
Message-ID: <538CE2CA.9060806@us.thalesgroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thsbbuxrt01p.us.thalesgroup.com ([192.93.163.25]:29139 "EHLO
	thsbbuxrt01p.us.thalesgroup.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753894AbaFBVBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:01:06 -0400
Received: from thsbbuxrt01p.us.thalesgroup.com (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id B117A1809DE
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 16:55:20 -0400 (EDT)
Received: from thsbbuirt02p.us.thales (unknown [10.95.3.16])
	by thsbbuxrt01p.us.thalesgroup.com (Postfix) with ESMTP id A51FC1809DD
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 16:55:20 -0400 (EDT)
Received: from THSBBUIAV02P.us.thales (mcafee2.us.thales [10.95.3.12])
	by thsbbuirt02p.us.thales (Postfix) with ESMTPS id 5892020001F
	for <netdev@vger.kernel.org>; Mon,  2 Jun 2014 16:53:29 -0400 (EDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRmVkb3JhIDIwIHg4Nl82NC4NCg0KQWNjb3JkaW5nIHRvICJtYW4gcGluZyIsIHBpbmcgc2hv
dWxkIHdvcmsgZnJvbSBhIHN1YmludGVyZmFjZSBzcGVjaWZ5aW5nDQplaXRoZXIgdGhlIGludGVy
ZmFjZSBuYW1lIG9yIGl0cyBhZGRyZXNzOg0KDQo+IC1JIGludGVyZmFjZQ0KPiAgICBpbnRlcmZh
Y2UgaXMgZWl0aGVyIGFuIGFkZHJlc3MsIG9yIGFuIGludGVyZmFjZSBuYW1lLiAgSWYgaW50ZXLi
gJANCj4gICAgZmFjZSBpcyBhbiBhZGRyZXNzLCBpdCBzZXRzIHNvdXJjZSBhZGRyZXNzIHRvICBz
cGVjaWZpZWQgIGludGVy4oCQDQo+ICAgIGZhY2UgYWRkcmVzcy4gIElmIGludGVyZmFjZSBpbiBh
biBpbnRlcmZhY2UgbmFtZSwgaXQgc2V0cyBzb3VyY2UNCj4gICAgaW50ZXJmYWNlIHRvIHNwZWNp
ZmllZCBpbnRlcmZhY2UuDQoNCkkndmUgZ290IGEgc3ViaW50ZXJmYWNlIGFuZCBJJ20gdHJ5aW5n
IHRvIHBpbmcgZnJvbSBpdC4NCg0KPiAjIGlmY29uZmlnIGV0aDM6c3ViMQ0KPiBldGgzOnN1YjE6
IGZsYWdzPTQxNjM8VVAsQlJPQURDQVNULFJVTk5JTkcsTVVMVElDQVNUPiAgbXR1IDE1MDANCj4g
ICAgICAgIGluZXQgMTcyLjE3LjMwLjE0MyAgbmV0bWFzayAyNTUuMjU1LjI1NC4wICBicm9hZGNh
c3QgMTcyLjE3LjMxLjI1NQ0KPiAgICAgICAgZXRoZXIgOTA6ZTI6YmE6MzQ6NDY6NDEgIHR4cXVl
dWVsZW4gMTAwMCAgKEV0aGVybmV0KQ0KPiAgICAgICAgZGV2aWNlIG1lbW9yeSAweGRjN2UwMDAw
LWRjODAwMDAwDQoNCklmIEkgcGluZyBmcm9tIHRoZSBhZGRyZXNzLCBpdCB3b3JrcyBhcyBzcGVj
aWZpZWQuIElmIEkgc3BlY2lmeSB0aGUNCmludGVyZmFjZSBuYW1lIGluc3RlYWQsIEkgc2VlOg0K
DQo+ICMgcGluZyAtSSBldGgzOnN1YjEgMTcyLjE3LjMwLjENCj4gcGluZzogU09fQklORFRPREVW
SUNFOiBJbnZhbGlkIGFyZ3VtZW50DQoNCkludmVzdGlnYXRpbmcgYSBsaXR0bGUgZGVlcGVyOg0K
DQo+ICMgc3RyYWNlIHBpbmcgLUkgZXRoMzpzdWIxIDE3Mi4xNy4zMC4xDQo+IGV4ZWN2ZSgiL3Vz
ci9iaW4vcGluZyIsIFsicGluZyIsICItSSIsICJldGgzOnN1YjEiLCAiMTcyLjE3LjMwLjEiXSwg
Wy8qIDM4IHZhcnMgKi9dKSA9IDANCj4gLi4uDQo+IHNldHNvY2tvcHQoNCwgU09MX1NPQ0tFVCwg
U09fQklORFRPREVWSUNFLCAiZXRoMzpzdWIxXDAiLCAxMykgPSAtMSBFTk9ERVYgKE5vIHN1Y2gg
ZGV2aWNlKQ0KPiAuLi4NCj4gKysrIGV4aXRlZCB3aXRoIDIgKysrDQoNCkFueSB0aG91Z2h0cz8N
Ci0tIA0KRGF2ZSBDbG9zZQ0K
