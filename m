From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] isdn: divamnt: use y2038-safe
 ktime_get_ts64() for trace data timestamps
Date: Sun, 17 Jan 2016 19:27:17 -0500 (EST)
Message-ID: <20160117.192717.1755604764104681063.davem@davemloft.net>
References: <20151120182307.GA3513@d830.WORKGROUP>
 <1452876685-2325-1-git-send-email-amsfield22@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: y2038@lists.linaro.org, mac@melware.de, isdn@linux-pingi.de,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: amsfield22@gmail.com
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1452876685-2325-1-git-send-email-amsfield22@gmail.com>
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

RnJvbTogQWxpc29uIFNjaG9maWVsZCA8YW1zZmllbGQyMkBnbWFpbC5jb20+CkRhdGU6IEZyaSwg
MTUgSmFuIDIwMTYgMDg6NTE6MjUgLTA4MDAKCj4gZGl2YW1udCBzdG9yZXMgYSBzdGFydF90aW1l
IGF0IG1vZHVsZSBpbml0IGFuZCB1c2VzIGl0IHRvIGNhbGN1bGF0ZQo+IGVsYXBzZWQgdGltZS4g
VGhlIGVsYXBzZWQgdGltZSwgc3RvcmVkIGluIHNlY3MgYW5kIHVzZWNzLCBpcyBwYXJ0IG9mCj4g
dGhlIHRyYWNlIGRhdGEgdGhlIGRyaXZlciBtYWludGFpbnMgZm9yIHRoZSBESVZBIFNlcnZlciBJ
U0ROIGNhcmRzLgo+IE5vIGNoYW5nZSB0byB0aGUgZm9ybWF0IG9mIHRoYXQgdGltZSBkYXRhIGlz
IHJlcXVpcmVkLgo+IAo+IFRvIGF2b2lkIG92ZXJmbG93IG9uIDMyLWJpdCBzeXN0ZW1zIHVzZSBr
dGltZV9nZXRfdHM2NCgpIHRvIHJldHVybgo+IHRoZSBlbGFwc2VkIG1vbm90b25pYyB0aW1lIHNp
bmNlIHN5c3RlbSBib290Lgo+IAo+IFRoaXMgaXMgYSBjaGFuZ2UgZnJvbSByZWFsIHRvIG1vbm90
b25pYyB0aW1lLiBTaW5jZSB0aGUgZHJpdmVyIG9ubHkKPiBzdG9yZXMgZWxhcHNlZCB0aW1lLCBt
b25vdG9uaWMgdGltZSBpcyBzdWZmaWNpZW50IGFuZCBtb3JlIHJvYnVzdAo+IGFnYWluc3QgcmVh
bCB0aW1lIGNsb2NrIGNoYW5nZXMuIFRoZXNlIG5ldyBtb25vdG9uaWMgdmFsdWVzIGNhbiBiZQo+
IG1vcmUgdXNlZnVsIGZvciBkZWJ1Z2dpbmcgYmVjYXVzZSB0aGV5IGNhbiBiZSBlYXNpbHkgY29t
cGFyZWQgdG8KPiBvdGhlciBtb25vdG9uaWMgdGltZXN0YW1wcy4KPiAKPiBOb3RlIGVsYXNwc2Vk
IHRpbWUgdmFsdWVzIHdpbGwgbm93IHN0YXJ0IGF0IHN5c3RlbSBib290IHRpbWUgcmF0aGVyCj4g
dGhhbiBtb2R1bGUgbG9hZCB0aW1lLCBzbyB0aGV5IHdpbGwgZGlmZmVyIHNsaWdodGx5IGZyb20g
cHJldmlvdXNseQo+IHJlcG9ydGVkIHZhbHVlcy4KPiAKPiBSZW1vdmUgZGVjbGFyYXRpb24gYW5k
IGluaXQgb2YgcHJldmlvdXNseSB1bnVzZWQgdGltZSBjb25zdGFudHM6Cj4gc3RhcnRfc2VjLCBz
dGFydF91c2VjLgo+IAo+IFNpZ25lZC1vZmYtYnk6IEFsaXNvbiBTY2hvZmllbGQgPGFtc2ZpZWxk
MjJAZ21haWwuY29tPgo+IFJldmlld2VkLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRl
PgoKUGxlYXNlIHJlc3VibWl0IHRoaXMgd2hlbiB0aGUgbmV0LW5leHQgdHJlZSBpcyBvcGVuIGFn
YWluLgoKVGhhbmsgeW91LgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczov
L2xpc3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
