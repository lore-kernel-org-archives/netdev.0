From: Jarno Rajahalme <jarno-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH nf-next v9 8/8] openvswitch: Interface with
	NAT.
Date: Thu, 10 Mar 2016 10:45:27 -0800
Message-ID: <947C7126-09A4-4C70-B638-F4A75C1BC52D@ovn.org>
References: <1457565024-27300-1-git-send-email-jarno@ovn.org>
 <1457565024-27300-8-git-send-email-jarno@ovn.org>
 <CAPWQB7GkhrfZaaT-LkTP7Esfj4tzU=Fgto2ZaSq4YkurhOf8bw@mail.gmail.com>
 <20160310120021.GA26693@pox.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20160310120021.GA26693-4EA/1caXOu0mYvmMESoHnA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Cj4gT24gTWFyIDEwLCAyMDE2LCBhdCA0OjAwIEFNLCBUaG9tYXMgR3JhZiA8dGdyYWZAc3V1Zy5j
aD4gd3JvdGU6Cj4gCj4gT24gMDMvMDkvMTYgYXQgMDc6NDdwbSwgSm9lIFN0cmluZ2VyIHdyb3Rl
Ogo+PiBPbiA5IE1hcmNoIDIwMTYgYXQgMTU6MTAsIEphcm5vIFJhamFoYWxtZSA8amFybm9Ab3Zu
Lm9yZz4gd3JvdGU6Cj4+PiBFeHRlbmQgT1ZTIGNvbm50cmFjayBpbnRlcmZhY2UgdG8gY292ZXIg
TkFULiAgTmV3IG5lc3RlZAo+Pj4gT1ZTX0NUX0FUVFJfTkFUIGF0dHJpYnV0ZSBtYXkgYmUgdXNl
ZCB0byBpbmNsdWRlIE5BVCB3aXRoIGEgQ1QgYWN0aW9uLgo+Pj4gQSBiYXJlIE9WU19DVF9BVFRS
X05BVCBvbmx5IG1hbmdsZXMgZXhpc3RpbmcgYW5kIGV4cGVjdGVkIGNvbm5lY3Rpb25zLgo+Pj4g
SWYgT1ZTX05BVF9BVFRSX1NSQyBvciBPVlNfTkFUX0FUVFJfRFNUIGlzIGluY2x1ZGVkIHdpdGhp
biB0aGUgbmVzdGVkCj4+PiBhdHRyaWJ1dGVzLCBuZXcgKG5vbi1jb21taXR0ZWQvbm9uLWNvbmZp
cm1lZCkgY29ubmVjdGlvbnMgYXJlIG1hbmdsZWQKPj4+IGFjY29yZGluZyB0byB0aGUgcmVzdCBv
ZiB0aGUgbmVzdGVkIGF0dHJpYnV0ZXMuCj4+PiAKPj4+IFRoZSBjb3JyZXNwb25kaW5nIE9WUyB1
c2Vyc3BhY2UgcGF0Y2ggc2VyaWVzIGluY2x1ZGVzIHRlc3QgY2FzZXMgKGluCj4+PiB0ZXN0cy9z
eXN0ZW0tdHJhZmZpYy5hdCkgdGhhdCBhbHNvIHNlcnZlIGFzIGV4YW1wbGUgdXNlcy4KPj4+IAo+
Pj4gVGhpcyB3b3JrIGV4dGVuZHMgb24gYSBicmFuY2ggYnkgVGhvbWFzIEdyYWYgYXQKPj4+IGh0
dHBzOi8vZ2l0aHViLmNvbS90Z3JhZi9vdnMvdHJlZS9uYXQuCj4+IAo+PiBUaG9tYXMsIEkgZ3Vl
c3MgdGhlcmUgd2FzIG5vdCBzaWdub2ZmIGluIHRoZXNlIHBhdGNoZXMgc28gSmFybm8gZG9lcwo+
PiBub3QgaGF2ZSB5b3VyIHNpZ25vZmYgaW4gdGhpcyBwYXRjaC4KPiAKPiBUaGF0J3MgZmluZS4g
VGhlIGNvZGUgaGFzIGV2b2x2ZWQgYSBsb3Qgc2luY2UuIEkgZG9uJ3Qgc2VlIGFueXRoaW5nCj4g
ZnVydGhlciB0aGFuIHdoYXQgSm9lIHNwb3R0ZWQgc28gZmVlbCBmcmVlIHRvIGFkZCBteQo+IAo+
IEFja2VkLWJ5OiBUaG9tYXMgR3JhZiA8dGdyYWZAc3V1Zy5jaD4KClRoYW5rcyEKCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QK
ZGV2QG9wZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGlu
Zm8vZGV2Cg==
