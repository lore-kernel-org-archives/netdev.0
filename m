From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: IPv6 support for
	ovs_tunnel_get_egress_info
Date: Fri, 2 Oct 2015 17:57:06 -0700
Message-ID: <CAEP_g=9WbT15vWUpUemq5c_b90U7LfbVRWDt0DSHGoqnqyZL+A@mail.gmail.com>
References: <cover.1443710454.git.jbenc@redhat.com>
 <8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
 <CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
 <20151002080041.52017d26@griffin>
 <CALnjE+qn7PrEYxKZ6c03-Bz63BcROVuqmwdp8sqi2eXvxY-yeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+qn7PrEYxKZ6c03-Bz63BcROVuqmwdp8sqi2eXvxY-yeg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

T24gRnJpLCBPY3QgMiwgMjAxNSBhdCAxMjozMiBQTSwgUHJhdmluIFNoZWxhciA8cHNoZWxhckBu
aWNpcmEuY29tPiB3cm90ZToKPiBPbiBUaHUsIE9jdCAxLCAyMDE1IGF0IDExOjAwIFBNLCBKaXJp
IEJlbmMgPGpiZW5jQHJlZGhhdC5jb20+IHdyb3RlOgo+PiBPbiBUaHUsIDEgT2N0IDIwMTUgMTc6
MTE6NTYgLTA3MDAsIFByYXZpbiBTaGVsYXIgd3JvdGU6Cj4+PiBJIGRvbnQgc2VlIHBvaW50IG9m
IGFkZGluZyB0aGlzIGNvZGUgd2hlbiBJUHY2IHNhbXBsaW5nIG5vdCBzdXBwb3J0IGJ5Cj4+PiB0
aGUgcGF0Y2ggc2VyaWVzLgo+Pgo+PiBJdCB3YXMgcmVxdWVzdGVkIGJ5IEplc3NlOgo+PiBodHRw
Oi8vYXJ0aWNsZS5nbWFuZS5vcmcvZ21hbmUubGludXgubmV0d29yay8zODAzNDgKPj4KPgo+IEkg
ZG9uJ3QgdGhpbmsgd2UgY2FuIHVzZSB0aGlzIGZ1bmN0aW9uLCBsd3R1bm5lbCBkZXZpY2UgbmVl
ZCBuZXcgbmRvXwo+IG9wZXJhdGlvbiB0byBleHBvcnQgdGhpcyBpbmZvcm1hdGlvbi4gU28gbGV0
cyBkZWZlciB0aGlzIHBhdGNoIHRpbGwgd2UKPiBoYXZlIHNvbHV0aW9uIGZvciByZXRyaWV2aW5n
IGVncmVzcyBpbmZvIGZyb20gbHd0dW5uZWwgZGV2aWNlcy4KCkkgZG9uJ3QgZW50aXJlbHkgZGlz
YWdyZWUgd2l0aCB0aGlzIGJ1dCBJJ20gYWxzbyBuZXJ2b3VzIGFib3V0CmNvbXBsZXRlbHkgbGVh
dmluZyBpdCBvdXQuIEl0IHNlZW1zIGxpa2Ugd2hlbiB0aGlzIGlzc3VlIGRvZXMgZ2V0CmZpeGVk
LCBpdCBpcyBsaWtlbHkgdGhhdCB0aGUgcGVyc29uIHdobyBkb2VzIGl0IHdpbGwganVzdCBjb252
ZXJ0CndoYXRldmVyIGNvZGUgaXMgdGhlcmUgYW5kIG5vdCBuZWNlc3NhcmlseSB0aGluayBhYm91
dCBJUHY2IHNpbmNlIGl0J3MKbm90IGFuIElQdjYgZmVhdHVyZS4gSWYgdGhhdCBoYXBwZW5zLCB3
ZSdsbCBoYXZlIGEgaGlkZGVuIHByb2JsZW0gaW4KSVB2Niwgd2hpY2ggaXMgc29tZXdoYXQgdW5m
b3J0dW5hdGVseSBhcyB0cnkgdG8gYWR2YW5jZSBJUHY2IGZvcndhcmQuCl9fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9w
ZW52c3dpdGNoLm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2
Cg==
