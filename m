From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Thu, 10 Dec 2015 17:27:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBEAB36@AcuExch.aculab.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
	 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
	 <20151209145917.GA3884@mrl.redhat.com>
	 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
	 <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBE9A61@AcuExch.aculab.com>
	 <1449676782.9768.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBE9B1C@AcuExch.aculab.com>
	 <566860BC.4040604@gmail.com> <56687EBB.5040108@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBEA7A3@AcuExch.aculab.com>
 <1449763097.9768.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"Dmitry Vyukov" <dvyukov@google.com>,
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
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449763097.9768.13.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0DQo+IFNlbnQ6IDEwIERlY2VtYmVyIDIwMTUgMTU6NTgNCj4NCj4g
QlRXLCBhcmUgeW91IGV2ZW4gdXNpbmcgSVB2NiBTQ1RQIHNlc3Npb25zID8NCg0KT3VyIE0zVUEv
U0NUUCBwcm90b2NvbCBzdGFjayBzdXBwb3J0cyB0aGVtIGFuZCBkZWZhdWx0cyB0byB1c2luZw0K
SVB2NiBsaXN0ZW5pbmcgc29ja2V0cyBmb3IgSVB2NCBjb25uZWN0aW9ucy4NCg0KSSB2ZXJ5IG11
Y2ggZG91YnQgdGhhbiBhbnkgY3VzdG9tZXJzIGhhdmUgdXNlZCB0aGVtIHlldC4NClNvIG1vc3Qg
b2YgdGhlIElQdjYgY29ubmVjdGlvbnMgd2lsbCBoYXZlIGJlZW4gdG8gOjoxDQpkdXJpbmcgaW50
ZXJuYWwgcmVncmVzc2lvbiB0ZXN0aW5nLg0KDQpXZSBkb24ndCBldmVuIHRyeSB0byBzZXQgYW55
IElQdjYgKG9yIElQdjQpIG9wdGlvbnMuDQoNCkp1c3QgU09fUkVVU0VBRERSLCBUQ1AvU0NUUF9O
T0RFTEFZLCBTQ1RQX0VWRU5UUywgU0NUUF9JTklUTVNHLA0KU09fS0VFUEFMSVZFICh0Y3ApLCBJ
UFY2X1Y2T05MWSAoaWYgYmluZGluZyBzZXBhcmF0ZSBsaXN0ZW5lcnMpLA0KU0NUUF9TT0NLT1BU
X0JJTlhfQUREIChXVEYgaXMgdGhpcyBhICdzb2NrZXQgb3B0aW9uJykgYW5kDQpTT19MSU5HRVIg
KHRvIGdldCBhYm9ydGl2ZSBjbG9zZSBvbiBTQ1RQIGNvbm5lY3Rpb25zIG9uIGtlcm5lbHMNCmJl
Zm9yZSAzLjE4KS4NCg0KCURhdmlkDQoNCg==
