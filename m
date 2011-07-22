From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH net-2.6] jme: Fix unmap error (Causing system
	freeze)
Date: Fri, 22 Jul 2011 16:49:43 +0800
Message-ID: <20110722083637.M71863@cooldavid.org>
References: <1311217056-9073-1-git-send-email-cooldavid@cooldavid.org>
	<CAHXqBF+1aJ0O9WxrZTKfYMm57emysfPUnA-=M9DZN5kUGnhW8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jason Lamb <jason@lambhome.org>, linux-netdev <netdev@vger.kernel.org>,
        Jason Long <jason@octgsoftware.com>, stable@kernel.org,
        Marcus Becker <marcus.disi@gmail.com>,
        Aries Lee <arieslee@jmicron.com>, Devinchiu <devinchiu@jmicron.com>,
        Marc Schiffbauer <mschiff@gentoo.org>,
        David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw_?=<mirqus@gmail.com>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <CAHXqBF+1aJ0O9WxrZTKfYMm57emysfPUnA-=M9DZN5kUGnhW8g@mail.gmail.com>
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

T24gRnJpLCAyMiBKdWwgMjAxMSAwOTo0NTo0MiArMDIwMCwgTWljaGHFgiBNaXJvc8WCYXcgd3Jv
dGUKPiAyMDExLzcvMjEgIDxjb29sZGF2aWRAY29vbGRhdmlkLm9yZz46Cj4gPiBGcm9tOiBHdW8t
RnUgVHNlbmcgPGNvb2xkYXZpZEBjb29sZGF2aWQub3JnPgo+ID4KPiA+IFRoaXMgcGF0Y2ggYWRk
IHRoZSBtaXNzaW5nIGRtYV91bm1hcCgpLgo+ID4gV2hpY2ggc29sdmVkIHRoZSBjcml0aWNhbCBp
c3N1ZSBvZiBzeXN0ZW0gZnJlZXplIG9uIGhlYXZ5IGxvYWQuCj4gPgo+ID4gTWljaGFsIE1pcm9z
bGF3J3MgcmVqZWN0ZWQgcGF0Y2g6Cj4gPiBbUEFUQ0ggdjIgMTAvNDZdIG5ldDogam1lOiBjb252
ZXJ0IHRvIGdlbmVyaWMgRE1BIEFQSQo+ID4gUG9pbnRlZCBvdXQgdGhlIGlzc3VlIGFsc28sIHRo
YW5rIHlvdSBNaWNoYWwuCj4gPiBCdXQgdGhlIGZpeCB3YXMgaW5jb3JyZWN0LiBJdCB3b3VsZCB1
bm1hcCBuZWVkZWQgYWRkcmVzcwo+ID4gd2hlbiBsb3cgbWVtb3J5Lgo+IAo+IE15IHBhdGNoIGFs
c28gZml4ZWQgYW5vdGhlciBpc3N1ZSAtIGZyb20gY29ycmVjdG5lc3MgcG9pbnQgb2YgdmlldywK
PiB5b3Ugc2hvdWxkIG5vdCB1c2UgdmlydF90b19wYWdlK2RtYV9tYXBfcGFnZSBoZXJlLCBidXQg
ZG1hX21hcF9zaW5nbGUuCj4gCj4gQmVzdCBSZWdhcmRzLAo+IE1pY2hhxYIgTWlyb3PFgmF3Ckhp
IE1pY2hhxYI6CgpZZXMsIEkgZGlkIG5vdGljZWQgdGhhdC4gOikKCkFuZCBJIGFncmVlZCB0aGF0
IHVzaW5nIHtkbWF8cGNpfV9tYXBfc2luZ2xlIGlzIGJldHRlciB0aGFuCmNhbGxpbmcgdmlydF90
b19wYWdlIGluIGRyaXZlci4KCkl0J3MganVzdCB0aGF0IEknbSBub3Qgc3VyZSBpZiBpdCBpcyBy
ZWFsbHkgcHJlZmVycmVkIHRvIHVzZQpkbWFfbWFwX3NpbmdsZSBvdmVyIHBjaV9tYXBfc2luZ2xl
IGZvciBQQ0kgZGV2aWNlIGRyaXZlcj8KCllvdSBhcmUgdmVyeSB3ZWxjb21lIHRvIHNlbmQgYW5v
dGhlciBwYXRjaCBmb3IgY29udmVydGluZyB0aGUKRE1BIEFQSSB1c2luZy4KCkd1by1GdSBUc2Vu
ZwoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18Kc3RhYmxl
IG1haWxpbmcgbGlzdApzdGFibGVAbGludXgua2VybmVsLm9yZwpodHRwOi8vbGludXgua2VybmVs
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL3N0YWJsZQo=
