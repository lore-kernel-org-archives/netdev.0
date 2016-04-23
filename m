From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Sat, 23 Apr 2016 02:30:58 +0100
Message-ID: <CAB=NE6X35iUW2RQvayREEBvu8ULdTBqKALm6AEQNhh570_XbPA@mail.gmail.com>
References: <20160413060916.GA21184@localhost> <5521267.mr5HLCdTY6@wuerfel>
 <1460896953.15362.2.camel@sipsolutions.net>
 <4679823.7bDEQhE9qO@wuerfel>
 <1461056272.2766.8.camel@sipsolutions.net>
 <87inz9y0qg.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arnd Bergmann <arnd@arndb.de>, y2038@lists.linaro.org,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, Tina Ruchandani <ruchandani.tina@gmail.com>,
 Johannes Berg <johannes@sipsolutions.net>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <87inz9y0qg.fsf@purkki.adurom.net>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

T24gQXByIDIyLCAyMDE2IDg6MDkgUE0sICJLYWxsZSBWYWxvIiA8a3ZhbG9AY29kZWF1cm9yYS5v
cmc+IHdyb3RlOgo+Cj4gSm9oYW5uZXMgQmVyZyA8am9oYW5uZXNAc2lwc29sdXRpb25zLm5ldD4g
d3JpdGVzOgo+Cj4gPiBPbiBNb24sIDIwMTYtMDQtMTggYXQgMDA6MTAgKzAyMDAsIEFybmQgQmVy
Z21hbm4gd3JvdGU6Cj4gPj4gT24gU3VuZGF5IDE3IEFwcmlsIDIwMTYgMTQ6NDI6MzMgSm9oYW5u
ZXMgQmVyZyB3cm90ZToKPiA+PiA+Cj4gPj4gPiBJIHdhcyB0aGlua2luZyBtb3JlIHJlc3RyaWN0
aXZlbHkgb2YganVzdCB0aGUgc3R1ZmYgdGhhdCBjYW4ndCBldmVuCj4gPj4gPiBiZSBidWlsdCB3
aXRob3V0IG1vZGlmeWluZyB0aGUgc291cmNlcyAtIGxpa2UgdGhlICIjaWYgVkVSQk9TRSIKPiA+
PiA+IHRoaW5nLgo+ID4+Cj4gPj4gQWxsIHRoZSBERUJVRygpIHN0YXRlbWVudHMgYXJlIGluc2lk
ZSBvZiB0aGlzIGtpbmQgb2YgY2hlY2ssIHNvIGlmIHdlCj4gPj4gcmVtb3ZlIHRoZSAjaWZkZWZz
LCBpdCB3b3VsZCBiZSBsb2dpY2FsIHRvIHJlbW92ZSB0aGUgcmVzdCBvZiB0aGUKPiA+PiBkZWJ1
Z2dpbmcgaW5mcmFzdHJ1Y3R1cmUgKERFQlVHKCkgbWFjcm9zLCBTSE9XXyosIHBjX2RlYnVnLCBt
YXliZQo+ID4+IG1vcmUpIGFzIHdlbGwuCj4gPgo+ID4gU2VlbXMgcmVhc29uYWJsZS4KPiA+Cj4g
PiBNYXliZSB3ZSBzaG91bGQgQ2MgdGhlIG1haW50YWluZXIsIGJ1dCBJIHN1c3BlY3QgdGhhdCBz
aW5jZSB0aGUgZHJpdmVyCj4gPiBpcyBtYXJrZWQgT2Jzb2xldGUgYW55d2F5IEx1aXMgd29uJ3Qg
Y2FyZSBlaXRoZXIgOikKPgo+IEknbSBwbGFubmluZyB0byBhcHBseSB0aGlzIHBhdGNoIGFueXdh
eSwgdGhlIGRlYnVnZ2luZyBpbmZyYXN0cnVjdHVyZQo+IHJlbW92YWwgY2FuIGJlIGEgZm9sbG93
dXAgcGF0Y2guIEJ1dCBwbGVhc2UgbGV0IG1lIGtub3cgaWYgSSBzaG91bGQgZHJvcAo+IHRoaXMg
aW5zdGVhZC4KCkknZCBzYXkgbGV0J3MgYnVyeSB0aGUgZHJpdmVyIG5vdy4gV2UgaGF2ZSBhIHBy
b2Nlc3MgdG8gc3RhZ2UgbGFyZ2UgY2h1bmtzCm9mIHBvbyBub3cgdGhyb3VnaCBzdGFnaW5nLCBs
ZXQncyB1c2UgdGhhdCB0byBzaGFmdCBwcmlzbTU0IHRoZXJlIG5vdyBhbmQKZ2l2ZSBpdCBhIGZl
dyBjeWNsZXMgdG8gbGV0IHBlb3BsZSBjYWxsIGJsb29keSBtdXJkZXIgYmVmb3JlIGZpbmFsbHkK
cmVtb3ZpbmcuIFdlIG5lZWQgdG8gZG8gYmV0dGVyIGF0IGRlbGV0aW5nIGFuY2llbnQgbGVnYWN5
IHNoaXQuIEknbGwgc3RhbmQKYmVoaW5kIHRoaXMgb25lLiBTdWUgbWUgaWYgbmVlZGVkLgoKICBM
dWlzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClkyMDM4
IG1haWxpbmcgbGlzdApZMjAzOEBsaXN0cy5saW5hcm8ub3JnCmh0dHBzOi8vbGlzdHMubGluYXJv
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL3kyMDM4Cg==
