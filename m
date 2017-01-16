From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: sctp: kernel memory overwrite attempt detected in
 sctp_getsockopt_assoc_stats
Date: Mon, 16 Jan 2017 14:50:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0264AD2@AcuExch.aculab.com>
References: <CACT4Y+ZDPa+spEh6P_ip9=hsNfeZ8KJfwJu5jTrPKVkGJUaZSg@mail.gmail.com>
 <20170115203515.GA6274@neilslaptop.think-freely.org>
 <CACT4Y+Zp4cruuKtf7fkSeLFbYLzTOD79Y2c+cCrHx-pbEXC_6A@mail.gmail.com>
 <20170116135743.GC30105@hmswarspite.think-freely.org>
 <CACT4Y+aoRnZyPYM=Bz3RLWhK+MYrQJBZ22TijJd=fzHp9KG+9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: 'Dmitry Vyukov' <dvyukov@google.com>,
        Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:55198 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdAPOvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 09:51:01 -0500
In-Reply-To: <CACT4Y+aoRnZyPYM=Bz3RLWhK+MYrQJBZ22TijJd=fzHp9KG+9A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRG1pdHJ5IFZ5dWtvdg0KPiBTZW50OiAxNiBKYW51YXJ5IDIwMTcgMTQ6MDQNCj4gPj4g
Pj4gSSd2ZSBlbmFibGVkIENPTkZJR19IQVJERU5FRF9VU0VSQ09QWV9QQUdFU1BBTiBvbiBzeXpr
YWxsZXIgZnV6emVyIGFuZA0KLi4uDQo+ID4+IFRoZSBjb2RlIGFsc28gdGFrZXMgaW50byBhY2Nv
dW50IGNvbXBvdW5kIHBhZ2VzLiBBcyBmYXIgYXMgSQ0KPiA+PiB1bmRlcnN0YW5kIHRoZSBpbnRl
bnRpb24gb2YgdGhlIGNoZWNrIGlzIHRvIGVmZmVjdGl2ZWx5IGZpbmQNCj4gPj4gb3V0LW9mLWJv
dW5kcyBjb3BpZXMgKGUuZy4gZ29lcyBiZXlvbmQgdGhlIGN1cnJlbnQgaGVhcCBhbGxvY2F0aW9u
KS4gSQ0KPiA+PiB3b3VsZCBleHBlY3QgdGhhdCBzdGFja3MgYXJlIGFsbG9jYXRlZCBhcyBjb21w
b3VuZCBwYWdlcyBhbmQgZG9uJ3QNCj4gPj4gdHJpZ2dlciB0aGlzIGNoZWNrLiBJIGRvbid0IHNl
ZSBpdCBpcyBmaXJpbmcgaW4gb3RoZXIgc2ltaWxhciBwbGFjZXMuDQo+ID4+DQo+ID4gSG9uZXN0
bHksIEknbSBub3Qgb3Zlcmx5IGZhbWlsaWFyIHdpdGggc3RhY2sgcGFnZSBhbGxvY2F0aW9uLCBh
dCBsZWFzdCBub3Qgc28NCj4gPiBmYXIgYXMgY29tcG91bmQgdnMuIHNpbmdsZSBwYWdlIGFsbG9j
YXRpb24gaXMgY29uY2VybmVkLiAgSSBzdXBwb3NlIHRoZSBxdWVzdGlvbg0KPiA+IHlvdXIgcmVh
bGx5IGFza2luZyBoZXJlIGlzOiBIYXZlIHlvdSBmb3VuZCBhIGNhc2UgaW4gd2hpY2ggdGhlIHN5
c2NhbGwgZnV6emVyDQo+ID4gaGFzIGZvcmNlZCB0aGUgYWxsb2NhdGlvbiBvZiBhbiBpbnNlY3Vy
ZSBub24tY29tcG91bmQgcGFnZSBvbiB0aGUgc3RhY2ssIG9yIGlzDQo+ID4gdGhpcyBhIGZhbHNl
IHBvc2l0aXZlIHdhcm5pbmcuICBJIGNhbid0IHByb3ZpZGUgdGhlIGFuc3dlciB0byB0aGF0Lg0K
PiANCj4gWWVzLiBJIGFkZGVkIEtlZXMsIGF1dGhvciBvZiBDT05GSUdfSEFSREVORURfVVNFUkNP
UFlfUEFHRVNQQU4sIHRvIFRvIGxpbmUuDQo+IEtlZXMsIGlzIHRoaXMgYSBmYWxzZSBwb3NpdGl2
ZT8NCg0KSSdkIGd1ZXNzIHRoYXQgdGhlIGtlcm5lbCBzdGFjayBpcyAoc29tZWhvdykgYWxsb2Nh
dGVkIHBhZ2UgYnkgcGFnZQ0KcmF0aGVyIHRoYW4gYnkgYSBzaW5nbGUgbXVsdGktcGFnZSBhbGxv
Y2F0ZS4NCk9yIG1heWJlIHZtYWxsb2MoKSBpc24ndCBzZXR0aW5nIHRoZSByZXF1aXJlZCBmbGFn
Pz8NCg0KCURhdmlkDQoNCg==
