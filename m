From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Wed, 9 Dec 2015 15:49:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
	 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
	 <20151209145917.GA3884@mrl.redhat.com>
	 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Vlad Yasevich" <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	"Alexander Potapenko" <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBTQ1RQIGlzIGxhY2tpbmcgcHJvcGVyIG5wLT5vcHQgY2xvbmluZyBhdCBhY2NlcHQoKSB0aW1l
Lg0KPiANCj4gVENQIGFuZCBEQ0NQIHVzZSBpcHY2X2R1cF9vcHRpb25zKCkgaGVscGVyLCBkbyB0
aGUgc2FtZSBpbiBTQ1RQLg0KPiANCj4gV2UgbWlnaHQgbGF0ZXIgZmFjdG9yaXplIHRoaXMgY29k
ZSBpbiBhIGNvbW1vbiBoZWxwZXIgdG8gYXZvaWQNCj4gZnV0dXJlIG1pc3Rha2VzLg0KDQpJJ20g
d29uZGVyaW5nIHdoYXQgdGhlIHJlYWwgaW1wYWN0IG9mIHRoaXMgYW5kIHRoZSBvdGhlciByZWNl
bnQNClNDVFAgYnVncy9wYXRjaGVzIGlzIG9uIHJlYWwgd29ya2xvYWRzPw0KV2UgaGF2ZSBlbm91
Z2ggdHJvdWJsZSBnZXR0aW5nIG91ciBjdXN0b21lcnMgdG8gdXNlIGtlcm5lbHMNCmxhdGVyIHRo
YXQgdGhlIDIuNi4xOCBiYXNlZCBSSEVMNSAtIHdpdGhvdXQgaGF2aW5nIHRvIHBlcnN1YWRlDQp0
aGVtIHRvIHVzZSBrZXJuZWxzIHRoYXQgY29udGFpbiB2ZXJ5IHJlY2VudCBmaXhlcy4NCg0KCURh
dmlkDQoNCg==
