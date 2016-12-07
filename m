From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Wed, 7 Dec 2016 17:09:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0237532@AcuExch.aculab.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com>
 <1481044098.7129.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: 'Paolo Abeni' <pabeni@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:60606 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbcLGRJt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:09:49 -0500
In-Reply-To: <1481044098.7129.7.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogUGFvbG8gQWJlbmkNCj4gU2VudDogMDYgRGVjZW1iZXIgMjAxNiAxNzowOA0KLi4uDQo+
IEBAIC03OSw2ICs4Miw5IEBAIHN0cnVjdCB1ZHBfc29jayB7DQo+ICAJaW50CQkJKCpncm9fY29t
cGxldGUpKHN0cnVjdCBzb2NrICpzaywNCj4gIAkJCQkJCXN0cnVjdCBza19idWZmICpza2IsDQo+
ICAJCQkJCQlpbnQgbmhvZmYpOw0KPiArDQo+ICsJLyogc2luY2Ugd2UgYXJlIHByb25lIHRvIGRy
b3BzLCBhdm9pZCBkaXJ0eWluZyBhbnkgc2sgY2FjaGVsaW5lICovDQo+ICsJYXRvbWljX3QJCWRy
b3BzIF9fX19jYWNoZWxpbmVfYWxpZ25lZF9pbl9zbXA7DQo+ICB9Ow0KDQpJc24ndCB0aGF0IGxp
a2VseSB0byBjcmVhdGUgYSBsYXJnZSBob2xlIG9uIHN5c3RlbXMgd2l0aCBsYXJnZSBjYWNoZSBs
aW5lcy4NCihTYW1lIGFzIGFueSBvdGhlciB1c2Ugb2YgX19fX2NhY2hlbGluZV9hbGlnbmVkX2lu
X3NtcC4pDQoNCglEYXZpZA0KDQo=
