From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [Make-wifi-fast] [RFCv2 1/3] mac80211: implement
 fq_codel for software queuing
Date: Tue, 22 Mar 2016 07:51:06 +0100
Message-ID: <CA+BoTQ=PWCK6cq83sthqRRt0xYWBOORbb=0+QHM6XVaWCWVhDw@mail.gmail.com>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
 <1458123478-1795-2-git-send-email-michal.kazior@tieto.com>
 <alpine.DEB.2.02.1603211830000.26766@nftneq.ynat.uz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
 Network Development <netdev@vger.kernel.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 codel@lists.bufferbloat.net, make-wifi-fast@lists.bufferbloat.net,
 Johannes Berg <johannes@sipsolutions.net>, Tim Shepard <shep@alum.mit.edu>
To: David Lang <david@lang.hm>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <alpine.DEB.2.02.1603211830000.26766@nftneq.ynat.uz>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
 <mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Errors-To: codel-bounces@lists.bufferbloat.net
Sender: "Codel" <codel-bounces@lists.bufferbloat.net>
List-Id: netdev.vger.kernel.org

T24gMjIgTWFyY2ggMjAxNiBhdCAwMjozNSwgRGF2aWQgTGFuZyA8ZGF2aWRAbGFuZy5obT4gd3Jv
dGU6Cj4gT24gV2VkLCAxNiBNYXIgMjAxNiwgTWljaGFsIEthemlvciB3cm90ZToKPgo+PiBTaW5j
ZSAxMW4gYWdncmVnYXRpb24gYmVjb21lIGltcG9ydGFudCB0byBnZXQgdGhlCj4+IGJlc3Qgb3V0
IG9mIHR4b3BzLiBIb3dldmVyIGFnZ3JlZ2F0aW9uIGluaGVyZW50bHkKPj4gcmVxdWlyZXMgYnVm
ZmVyaW5nIGFuZCBxdWV1aW5nLiBPbmNlIHZhcmlhYmxlCj4+IG1lZGl1bSBjb25kaXRpb25zIHRv
IGRpZmZlcmVudCBhc3NvY2lhdGVkIHN0YXRpb25zCj4+IGlzIGNvbnNpZGVyZWQgaXQgYmVjYW1l
IGFwcGFyZW50IHRoYXQgYnVmZmVyYmxvYXQKPj4gY2FuJ3QgYmUgc2ltcGx5IGZvdWdodCB3aXRo
IHFkaXNjcyBmb3Igd2lyZWxlc3MKPj4gZHJpdmVycy4KPgo+IElmIHRoZSBuZXR3b3JrIGlzIHF1
aWV0IGVub3VnaCwgZG9uJ3QgZG8gYW55IGJ1ZmZlcmluZywgYnV0IGluIGFsbW9zdCBhbGwKPiBz
aXR1YXRpb25zIHlvdSBhcmUgZ29pbmcgdG8gbmVlZCB0byBidWZmZXIgc3RhcnRpbmcgbm8gbGF0
ZXIgdGhhbiB0aGUgc2Vjb25kCj4gcGFja2V0IHlvdSB0cnkgdG8gc2VuZC4KPgo+IERvbid0IHRy
eSB0byBtYWtlIHF1ZXVlaW5nIG9jY3VyLCBqdXN0IGRlYWwgd2l0aCB0aGUgcXVldWVzIHRoYXQg
Zm9ybQo+IG5hdHVyYWxseSBiZWNhdXNlIHlvdSBjYW4ndCB0cmFuc21pdCBkYXRhIGFueSBmYXN0
ZXIgKGFuZCB3b3JrIHRvIGtlZXAgdGhlbQo+IHVuZGVyIHNvbWUgc2VtYmxlbmNlIG9mIGNvbnRy
b2wpClsuLi5dCgpUaGlzIGlzIHdoYXQgYWxyZWFkeSBoYXBwZW5zLiBRdWV1ZXMgdHlwaWNhbGx5
IHN0YXJ0IHRvIGJ1aWxkIHVwIHdoZW4KaGFyZHdhcmUgdHggZmlmb3MvcXVldWVzIGJlY29tZSBi
dXN5IHNvIGJ5IHRoZSB0aW1lIHRoZXkgYmVjb21lCmF2YWlsYWJsZSB5b3UgbWlnaHQgaGF2ZSBh
IGJ1bmNoIG9mIGZyYW1lcyB5b3UgY2FuIGFnZ3JlZ2F0ZS4KClRoZSBwYXRjaCBpcyBtb3JlIGFi
b3V0IGdldHRpbmcgcmlkIG9mIHFkaXNjcyBiZWNhdXNlIGl0J3MgaW5oZXJlbnRseQpoYXJkIHRv
IHRlYWNoIHRoZW0gaG93IDgwMi4xMSBhZ2dyZWdhdGlvbiB3b3JrcyAocGVyLXN0YXRpb24gcGVy
LXRpZCkKYW5kIHRoZSBldmVyLWNoYW5naW5nIG5hdHVyZSBvZiBwZXItc3RhdGlvbiB0eCBjb25k
aXRpb25zLgoKSSdsbCB1cGRhdGUgdGhlIGNvbW1pdCBsb2cgdG8gYmV0dGVyIHJlZmxlY3Qgd2hh
dCBpcyBiZWluZyBkb25lLgoKCk1pY2hhxYIKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX18KQ29kZWwgbWFpbGluZyBsaXN0CkNvZGVsQGxpc3RzLmJ1ZmZlcmJs
b2F0Lm5ldApodHRwczovL2xpc3RzLmJ1ZmZlcmJsb2F0Lm5ldC9saXN0aW5mby9jb2RlbAo=
