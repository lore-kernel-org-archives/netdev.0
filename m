From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Mon, 30 Jan 2017 14:31:58 -0500
Message-ID: <07a315d6-7c97-6d11-fa18-548000107c2f@oracle.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
 <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
 <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
 <1485803209.6360.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: jgross@suse.com, wei.liu2@citrix.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org, vineethp@amazon.com,
 xen-devel@lists.xenproject.org, paul.durrant@citrix.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1485803209.6360.111.camel@edumazet-glaptop3.roam.corp.google.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gMDEvMzAvMjAxNyAwMjowNiBQTSwgRXJpYyBEdW1hemV0IHdyb3RlOgo+IE9uIE1vbiwgMjAx
Ny0wMS0zMCBhdCAxMzoyMyAtMDUwMCwgQm9yaXMgT3N0cm92c2t5IHdyb3RlOgo+Cj4+IFdlIGRv
IG5ldGlmX2NhcnJpZXJfb2ZmKCkgZmlyc3QgdGhpbmcgaW4geGVubmV0X2Rpc2Nvbm5lY3RfYmFj
a2VuZCgpIGFuZAo+PiB0aGUgb25seSBwbGFjZSB3aGVyZSB0aGUgdGltZXIgaXMgcmVhcm1lZCBp
cyB4ZW5uZXRfYWxsb2NfcnhfYnVmZmVycygpLAo+PiB3aGljaCBpcyBndWFyZGVkIGJ5IG5ldGlm
X2NhcnJpZXJfb2soKSBjaGVjay4KPiBPaCB3ZWxsLCB0ZXN0aW5nIG5ldGlmX2NhcnJpZXJfb2so
KSBpbiBwYWNrZXQgcHJvY2Vzc2luZyBmYXN0IHBhdGggbG9va3MKPiB1bnVzdWFsIGFuZCBhIHdh
c3RlIG9mIGNwdSBjeWNsZXMuIEkndmUgbmV2ZXIgc2VlbiB0aGF0IHBhdHRlcm4gYmVmb3JlLgo+
Cj4gSWYgb25lIGRheSwgd2UgcmVtb3ZlIHRoaXMgbmV0aWZfY2Fycmllcl9vaygpIHRlc3QgZHVy
aW5nIGEgY2xlYW51cCwKPiB0aGVuIHRoZSByYWNlIHdpbmRvdyB3aWxsIG9wZW4gYWdhaW4uCgoK
SSBkb24ndCBrbm93IG11Y2ggYWJvdXQgbmFwaSBidXQgSSB3b25kZXIgd2hldGhlciBJIGNhbiBp
bmRlZWQgZGlzYWJsZQppdCBpbiB4ZW5uZXRfZGlzY29ubmVjdF9iYWNrZW5kKCkuIEkgZG9uJ3Qg
c2VlIGhvdyBhbnl0aGluZyBjYW4gaGFwcGVuCmFmdGVyIGRpc2Nvbm5lY3Qgc2luY2UgaXQgdW5t
YXBzIHRoZSByaW5ncy4gQW5kIHRoZW4gbmFwaSBpcyByZS1lbmFibGVkCmR1cmluZyByZWNvbm5l
Y3Rpb24gaW4geGVubmV0X2NyZWF0ZV9xdWV1ZXMoKS4gSW4gd2hpY2ggY2FzZSBhbSBub3Qgc3Vy
ZQp0aGVyZSBpcyBhbnkgbmVlZCBmb3IgeGVubmV0X2Rlc3Ryb3lfcXVldWVzKCkgYXMgZXZlcnl0
aGluZyB0aGVyZSBjb3VsZApiZSBmb2xkZWQgaW50byB4ZW5uZXRfZGlzY29ubmVjdF9iYWNrZW5k
KCkuCgotYm9yaXMKCgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRw
czovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
