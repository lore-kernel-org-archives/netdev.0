From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 2 Nov 2015 09:37:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBC86F1@AcuExch.aculab.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Yuchung Cheng <ycheng@google.com>,
	"Paolo Abeni" <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"Florian Westphal" <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	"Marcelo Ricardo Leitner" <mleitner@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Willem de Bruijn" <willemb@google.com>,
	=?utf-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@c0d3.blue>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Andreas Petlund
To: =?utf-8?B?J0JlbmRpayBSw7hubmluZyBPcHN0YWQn?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1445633413-3532-3-git-send-email-bro.devel+kernel@gmail.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQmVuZGlrIFLDuG5uaW5nIE9wc3RhZA0KPiBTZW50OiAyMyBPY3RvYmVyIDIwMTUgMjE6
NTANCj4gUkRCIGlzIGEgbWVjaGFuaXNtIHRoYXQgZW5hYmxlcyBhIFRDUCBzZW5kZXIgdG8gYnVu
ZGxlIHJlZHVuZGFudA0KPiAoYWxyZWFkeSBzZW50KSBkYXRhIHdpdGggVENQIHBhY2tldHMgY29u
dGFpbmluZyBuZXcgZGF0YS4gQnkgYnVuZGxpbmcNCj4gKHJldHJhbnNtaXR0aW5nKSBhbHJlYWR5
IHNlbnQgZGF0YSB3aXRoIGVhY2ggVENQIHBhY2tldCBjb250YWluaW5nIG5ldw0KPiBkYXRhLCB0
aGUgY29ubmVjdGlvbiB3aWxsIGJlIG1vcmUgcmVzaXN0YW50IHRvIHNwb3JhZGljIHBhY2tldCBs
b3NzDQo+IHdoaWNoIHJlZHVjZXMgdGhlIGFwcGxpY2F0aW9uIGxheWVyIGxhdGVuY3kgc2lnbmlm
aWNhbnRseSBpbiBjb25nZXN0ZWQNCj4gc2NlbmFyaW9zLg0KDQpXaGF0IHNvcnQgb2YgdHJhZmZp
YyBmbG93cyBkbyB5b3UgZXhwZWN0IHRoaXMgdG8gaGVscD8NCg0KQW4gc3NoIChvciBzaW1pbGFy
KSBjb25uZWN0aW9uIHdpbGwgZ2V0IGFkZGl0aW9uYWwgZGF0YSB0byBzZW5kLA0KYnV0IHRoYXQg
c29ydCBvZiBkYXRhIGZsb3cgbmVlZHMgTmFnbGUgaW4gb3JkZXIgdG8gcmVkdWNlIHRoZQ0KbnVt
YmVyIG9mIHBhY2tldHMgc2VudC4NCk9UT0ggaXQgbWlnaHQgYmVuZWZpdCBmcm9tIGluY2x1ZGlu
ZyB1bmFja2VkIGRhdGEgaWYgdGhlIE5hZ2xlDQp0aW1lciBleHBpcmVzLg0KQmVpbmcgYWJsZSB0
byBzZXQgdGhlIE5hZ2xlIHRpbWVyIG9uIGEgcGVyLWNvbm5lY3Rpb24gYmFzaXMNCihvciBtYXli
ZSB1c2luZyBzb21ldGhpbmcgYmFzZWQgb24gdGhlIFJUVCBpbnN0ZWFkIG9mIDIgc2VjcykNCm1p
Z2h0IG1ha2UgcGFja2V0IGxvc3MgbGVzcyBwcm9ibGVtYXRpYy4NCg0KRGF0YSBmbG93cyB0aGF0
IGFscmVhZHkgaGF2ZSBOYWdsZSBkaXNhYmxlZCAocHJvYmFibHkgYW55dGhpbmcgdGhhdA0KaXNu
J3QgY29tbWFuZC1yZXNwb25zZSBhbmQgaXNuJ3QgdW5pZGlyZWN0aW9uYWwgYnVsayBkYXRhKSBh
cmUNCmxpa2VseSB0byBnZW5lcmF0ZSBhIGxvdCBvZiBwYWNrZXRzIHdpdGhpbiB0aGUgUlRULg0K
UmVzZW5kaW5nIHVuYWNrZWQgZGF0YSB3aWxsIGp1c3QgZWF0IGludG8gYXZhaWxhYmxlIG5ldHdv
cmsgYmFuZHdpZHRoDQphbmQgY291bGQgZWFzaWx5IG1ha2UgYW55IGNvbmdlc3Rpb24gd29yc2Uu
DQoNCkkgdGhpbmsgdGhhdCBtZWFucyB5b3Ugc2hvdWxkbid0IHJlc2VuZCBkYXRhIG1vcmUgdGhh
biBvbmNlLCBhbmQvb3INCnNob3VsZCBtYWtlIHN1cmUgdGhhdCB0aGUgcmVzZW50IGRhdGEgaXNu
J3QgYSBzaWduaWZpY2FudCBvdmVyaGVhZA0Kb24gdGhlIHBhY2tldCBiZWluZyBzZW50Lg0KDQoJ
RGF2aWQNCg0KDQo=
