From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next v2 1/4] skbuff: add stub to help computing
 crc32c on SCTP packets
Date: Wed, 1 Mar 2017 10:53:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE72817@AcuExch.aculab.com>
References: <1488202783.2713.67.camel@redhat.com>
 <56fcd0848eae2b0693797e09500892659323546c.1488199633.git.dcaratti@redhat.com>
 <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Tom Herbert <tom@herbertland.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp @ vger . kernel . org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:56791 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750968AbdCAKzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 05:55:20 -0500
In-Reply-To: <CAKgT0Udbs_=vanS+oF8ePXTNjEfsq9y==bhtQ-5Cxb-g+iO4bg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDI4IEZlYnJ1YXJ5IDIwMTcgMjI6NDYNCi4u
Lg0KPiBJIGRvbid0IHdhbnQgdG8gc2VlIGFueXRoaW5nICJjaGVja3N1bSIgb3IgImNzdW0iIHJl
bGF0ZWQgaW4gdGhlDQo+IG5hbWluZyB3aGVuIGl0IGNvbWVzIHRvIGRlYWxpbmcgd2l0aCBTQ1RQ
IHVubGVzcyB3ZSBhYnNvbHV0ZWx5IGhhdmUgdG8NCj4gaGF2ZSBpdC4gIFNvIGFueSBmdW5jdGlv
biBuYW1lcyBvciBzdHJ1Y3R1cmVzIHdpdGggc2N0cCBpbiB0aGUgbmFtZQ0KPiBzaG91bGQgY2Fs
bCBvdXQgImNyYzMyIiBvciAiY3JjIiwgcGxlYXNlIGRvbid0IHVzZSBjaGVja3N1bS4NCg0KVGhl
biBhbHNvIGNoYW5nZSBhbGwgdGhlIHBsYWNlcyB0aGF0IHJlZmVyIHRoZSBJUCAxJ3MgY29tcGxp
bWVudA0KY2hlY2tzdW0gdG8gaXBjaGVja3N1bS4NCg0KCURhdmlkDQoNCg==
