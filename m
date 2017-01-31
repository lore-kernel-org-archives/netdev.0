From: Vineeth Remanan Pillai <vineethp@amazon.com>
Subject: Re: [PATCH v2] xen-netfront: Fix Rx stall during
 network stress and OOM
Date: Tue, 31 Jan 2017 08:47:25 -0800
Message-ID: <7780bf0c-9fd0-1abf-77d3-983f5e6c4e08@amazon.com>
References: <1484771149-12699-1-git-send-email-vineethp@u480fcf3b67f557f68df1.ant.amazon.com>
 <66b10c64-936a-8001-6855-2ff1ed626642@amazon.com>
 <38ccfaea-0a65-a6f3-c19a-e6f9c0d4ef76@oracle.com>
 <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, xen-devel <xen-devel@lists.xen.org>,
 Paul Durrant <paul.durrant@citrix.com>, David Miller <davem@davemloft.net>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <989bd104-13a9-f25f-b857-24ec49781f9c@amazon.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

Ck9uIDAxLzMwLzIwMTcgMDg6NDcgQU0sIFZpbmVldGggUmVtYW5hbiBQaWxsYWkgd3JvdGU6Cj4K
PiBPbiAwMS8yOS8yMDE3IDAzOjA5IFBNLCBCb3JpcyBPc3Ryb3Zza3kgd3JvdGU6Cj4+Cj4+IFRo
ZXJlIGFyZSBjb3VwbGUgb2YgcHJvYmxlbXMgd2l0aCB0aGlzIHBhdGNoLgo+PiAxLiBUaGUgJ2lm
JyBjbGF1c2Ugbm93IGV2YWx1YXRlcyB0byB0cnVlIG9uIHByZXR0eSBtdWNoIGV2ZXJ5IGNhbGwg
dG8gCj4+IHhlbm5ldF9hbGxvY19yeF9idWZmZXJzKCkuCj4gVGhhbmtzIGZvciBjYXRjaGluZyB0
aGlzLiBJbiBteSB0ZXN0aW5nIEkgZGlkIG5vdCBub3RpY2UgdGhpcyAtIG1vc3RseSAKPiBiZWNh
dXNlIG9mIHRoZSBuYXR1cmUgb2YgdGhlIHdvcmtsb2FkIGluIG15IHRlc3RpbmcuCkkgYW0gd29y
a2luZyBvbiBhIHBhdGNoIHRvIHJldmVydCB0byB0aGUgb2xkIGJlaGF2aW9yIGFuZCBzb2x2ZSB0
aGUgUnggCnN0YWxsIGlzc3VlIGJ5IHNjaGVkdWxpbmcgdGhlIHRpbWVyIGlmIGFueSBvZiB0aGUg
Zm9sbG93aW5nCmNvbmRpdGlvbnMgYXJlIHRydWU6CiAgLSB1bmNvbnN1bWVkIHJlcXVlc3RzICsg
bmV3IHJlcXVlc3RzIDwgTkVUX1JYX1NMT1RTX01JTiAob2xkIGJlaGF2aW9yKQogIC0gc2tiIGFs
bG9jYXRpb25zIGZhaWwKCldpbGwgc2VuZCBvdXQgdGhlIHBhdGNoIGJ5IG5leHQgd2VlayBhZnRl
ciBJIGNhbiBkbyBzb21lIHRlc3RpbmcuCgpUaGFua3MsClZpbmVldGgKCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0
Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwK
