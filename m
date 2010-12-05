From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PATCH] filter: fix sk_filter rcu handling
Date: Sun, 05 Dec 2010 22:28:42 +0100
Message-ID: <1291584522.2806.304.camel@edumazet-laptop>
References: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
	<1291192967.2856.492.camel@edumazet-laptop>
	<18eaf7d286236427b1632b9af62be513@localhost>
	<20101201.101809.71122121.davem@davemloft.net>
	<1291357953.2854.46.camel@edumazet-laptop>
	<1291582432.2806.300.camel@edumazet-laptop>
	<20101205210840.GB7668@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, hagen@jauu.net, stable@kernel.org,
        xiaosuo@gmail.com, wirelesser@gmail.com,
        "Paul E.
	McKenney" <paulmck@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>, Pavel Emelyanov <xemul@openvz.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <20101205210840.GB7668@basil.fritz.box>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

TGUgZGltYW5jaGUgMDUgZMOpY2VtYnJlIDIwMTAgw6AgMjI6MDggKzAxMDAsIEFuZGkgS2xlZW4g
YSDDqWNyaXQgOgo+ID4gV2hpbGUgd29ya2luZyBvbiB0aGlzLCBJIGZvdW5kIGFuIGFubm95aW5n
IHByb2JsZW0gd2l0aCBjdXJyZW50IGNvZGUuCj4gPiAKPiA+IFRoaXMgcGF0Y2ggaXMgYSBzdGFi
bGUgY2FuZGlkYXRlLgo+IAo+IERvZXMgdGhpcyBhY3R1YWxseSBmaXggYSByZWFsIHdvcmxkIHBy
b2JsZW0gc29tZW9uZSBpcyBleHBlcmllbmNpbmc/IAo+ICJUaGVvcmV0aWNhbCByYWNlcyIgYXJl
IG5vcm1hbGx5IG91dHNpZGUgc3RhYmxlJ3Mgc2NvcGUuCj4gCj4gLUFuZGkKCkkgZ3Vlc3MgaXRz
IGEgc2VjdXJpdHkgcHJvYmxlbS4KCldlIGNhbiBwcm9iYWJseSB3cml0ZSBhIHByb2dyYW0sIHJ1
biBieSB1bnByaXZpbGVkZ2UgdXNlciB0byBjcmFzaCB0aGUKbWFjaGluZS4KCkkgYW0gbm90IHN1
cmUgSSB3YW50IHRvIHNwZW5kIHRpbWUgdG8gd3JpdGUgdGhpcyBwcm9ncmFtLCBJIGhhdmUgb3Ro
ZXIKbW9yZSBpbnRlcmVzdGluZyB0b3BpY3MsIGJ1dCBzb21lIGhhY2tlcnMgcHJvYmFibHkgd2Fu
dCB0by4KCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
c3RhYmxlIG1haWxpbmcgbGlzdApzdGFibGVAbGludXgua2VybmVsLm9yZwpodHRwOi8vbGludXgu
a2VybmVsLm9yZy9tYWlsbWFuL2xpc3RpbmZvL3N0YWJsZQo=
