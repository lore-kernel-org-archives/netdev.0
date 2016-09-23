From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Fri, 23 Sep 2016 13:35:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0107FEB@AcuExch.aculab.com>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
 <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton
	<akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>,
	"linux-man@vger.kernel.org" <linux-man@vger.kernel.org>
To: 'Vlastimil Babka' <vbabka@suse.cz>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

RnJvbTogVmxhc3RpbWlsIEJhYmthDQo+IFNlbnQ6IDIzIFNlcHRlbWJlciAyMDE2IDEwOjU5DQou
Li4NCj4gPiBJIHN1c3BlY3QgdGhhdCBmZHQtPm1heF9mZHMgaXMgYW4gdXBwZXIgYm91bmQgZm9y
IHRoZSBoaWdoZXN0IGZkIHRoZQ0KPiA+IHByb2Nlc3MgaGFzIG9wZW4gLSBub3QgdGhlIFJMSU1J
VF9OT0ZJTEUgdmFsdWUuDQo+IA0KPiBJIGdhdGhlcmVkIHRoYXQgdGhlIGhpZ2hlc3QgZmQgZWZm
ZWN0aXZlbHkgbGltaXRzIHRoZSBudW1iZXIgb2YgZmlsZXMsDQo+IHNvIGl0J3MgdGhlIHNhbWUu
IEkgbWlnaHQgYmUgd3JvbmcuDQoNCkFuIGFwcGxpY2F0aW9uIGNhbiByZWR1Y2UgUkxJTUlUX05P
RklMRSBiZWxvdyB0aGF0IG9mIGFuIG9wZW4gZmlsZS4NCg0KCURhdmlkDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
