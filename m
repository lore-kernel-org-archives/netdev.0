From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Fri, 23 Sep 2016 14:43:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0108161@AcuExch.aculab.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160922223411.GA17222@localhost.localdomain>
         <1474586490.28155.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160923124517.GB17222@localhost.localdomain>
         <1474638171.28155.18.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160923140932.GA9307@localhost.localdomain>
 <1474641392.28155.27.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "Neal Cardwell" <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:59334 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760186AbcIWOqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 10:46:51 -0400
In-Reply-To: <1474641392.28155.27.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDIzIFNlcHRlbWJlciAyMDE2IDE1OjM3DQo+IE9u
IEZyaSwgMjAxNi0wOS0yMyBhdCAxMTowOSAtMDMwMCwgTWFyY2VsbyBSaWNhcmRvIExlaXRuZXIg
d3JvdGU6DQo+ID4gT24gRnJpLCBTZXAgMjMsIDIwMTYgYXQgMDY6NDI6NTFBTSAtMDcwMCwgRXJp
YyBEdW1hemV0IHdyb3RlOg0KPiA+ID4gT24gRnJpLCAyMDE2LTA5LTIzIGF0IDA5OjQ1IC0wMzAw
LCBNYXJjZWxvIFJpY2FyZG8gTGVpdG5lciB3cm90ZToNCj4gPiA+DQo+ID4gPiA+IEF5ZS4gSW4g
dGhhdCBjYXNlLCB3aGF0IGFib3V0IHVzaW5nIHRhaWwgaW5zdGVhZCBvZiBlbmQ/DQo+ID4gPg0K
PiA+ID4NCj4gPiA+IFdoYXQgZG8geW91IG1lYW4gZXhhY3RseSA/DQo+ID4NCj4gPiBTb21ldGhp
bmcgbGlrZToNCj4gPiAtc2tiLT50cnVlc2l6ZSA9IFNLQl9UUlVFU0laRShza2JfZW5kX29mZnNl
dChza2IpKTsNCj4gPiArc2tiLT50cnVlc2l6ZSA9IFNLQl9UUlVFU0laRShza2JfdGFpbF9vZmZz
ZXQoc2tiKSk7DQo+IA0KPiBDZXJ0YWlubHkgbm90IDspDQo+IA0KPiBUaGlzIHdvdWxkIGJlIGx5
aW5nLg0KPiBXZSByZWFsbHkgd2FudCBhIHByZWNpc2UgbWVtb3J5IGFjY291bnRpbmcgdG8gYXZv
aWQgT09NLg0KPiANCj4gU29tZSBVU0IgZHJpdmVycyB1c2UgOEtCIGZvciB0aGVpciBza2ItPmhl
YWQsIHlvdSBkbyBub3Qgd2FudCB0byBwcmV0ZW5kDQo+IGl0cyA2NitORVRfU0tCX1BBRj1GIGJ5
dGVzIGp1c3QgYmVjYXVzZSB0aGVyZSBpcyBubyBwYXlsb2FkIGluIHRoZQ0KPiBwYWNrZXQuDQoN
Ckxhc3QgSSBsb29rIHNvbWUgb2YgdGhlIFVTQm5ldCBkcml2ZXJzIHVzZWQgNjRrKyBza2IgKGFu
ZCB0aGVuDQpsaWVkIGFib3V0IHRydWVzaXplKS4NCg0KVGhhdCB3aG9sZSB1c2JuZXQgc3R1ZmYg
bmVlZHMgYSByZXdvcmsgZm9yIHVzYjMgKHhoY2kpIHNvIHRoYXQgb25jZQ0KdGhlIHJpbmdzIChl
dGMpIGFyZSBhbGwgc2V0dXAgcGFja2V0IHRyYW5zZmVyIGxvb2tzIG11Y2ggbW9yZSBsaWtlDQph
IG5vcm1hbCBldGhlcm5ldCBkZXZpY2UuDQpJIHRoaW5rIGl0IG5lZWRzIHRvIHN0b3AgdHJ5aW5n
IHRvIHJlY2VpdmUgaW50byBza2IsIGluc3RlYWQganVzdA0KcmVjZWl2ZSBpbnRvIHVzYiBzaXpl
ZCBidWZmZXJzIC0gYW5kIHRoZW4gZ2VuZXJhdGUgc2tiIHRoYXQgY29udGFpbg0KdGhlIGV0aGVy
bmV0IGZyYW1lIGRhdGEuDQpOb3QgdGhhdCBJJ20gdm9sdW50ZWVyaW5nIDotKQ0KDQoJRGF2aWQN
Cg0K
