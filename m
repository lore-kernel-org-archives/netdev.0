From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] ip_gre: check packet length and mtu correctly
 in erspan_fb_xmit
Date: Fri, 6 Oct 2017 09:38:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD008B9C8@AcuExch.aculab.com>
References: <1507162445-18540-1-git-send-email-u9012063@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008AC42@AcuExch.aculab.com>
 <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Xin Long <lucien.xin@gmail.com>
To: 'William Tu' <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:51130 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752568AbdJFJiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 05:38:52 -0400
In-Reply-To: <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogV2lsbGlhbSBUdQ0KPiBTZW50OiAwNSBPY3RvYmVyIDIwMTcgMjI6MjENCi4uLg0KPiA+
PiAtICAgICBpZiAoc2tiLT5sZW4gPiBkZXYtPm10dSkgew0KPiA+PiArICAgICBpZiAoc2tiLT5s
ZW4gLSBkZXYtPmhhcmRfaGVhZGVyX2xlbiA+IGRldi0+bXR1KSB7DQo+ID4NCj4gPiBDYW4geW91
IGd1YXJhbnRlZSB0aGF0IHNrYi0+bGVuID4gZGV2X2hhcmRfaGVhZGVyX2xlbj8NCj4gPiBJdCBp
cyBwcm9iYWJseSBzYWZlciB0byBjaGVjayBza2ItPmxlbiA+IGRldi0+aGFyZF9oZWFkZXJfbGVu
ICsgZGV2LT5tdHUNCj4gPiBzaW5jZSB0aGF0IGFkZGl0aW9uIGlzbid0IGdvaW5nIHRvIG92ZXJm
bG93Lg0KPiBTdXJlLCBJIHdpbGwgZml4IGl0Lg0KPiANCj4gPg0KPiA+PiAgICAgICAgICAgICAg
IHBza2JfdHJpbShza2IsIGRldi0+bXR1KTsNCj4gPj4gICAgICAgICAgICAgICB0cnVuY2F0ZSA9
IHRydWU7DQo+ID4NCj4gPiBJcyB0aGF0IHBza2JfdHJpbSgpIG5vdyB0cnVuY2F0aW5nIHRvIHRo
ZSBjb3JyZWN0IHNpemU/DQo+IA0KPiBZb3UncmUgcmlnaHQsIG5vdyBJIHNob3VsZCB0cnVuY2F0
ZSB0byAoZGV2LT5tdHUgKyBkZXZfaGFyZF9oZWFkZXJfbGVuKQ0KDQpJdCBtaWdodCBiZSB3b3J0
aCBjYWNoaW5nIHRoYXQgbGVuZ3RoIGluIHRoZSBkZXYgc3RydWN0dXJlDQp0byBhdm9pZCB0aGUg
YXJpdGhtZXRpYyBvbiBldmVyeSBwYWNrZXQuDQoNCglEYXZpZA0KDQo=
