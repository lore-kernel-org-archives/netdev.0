From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Thu, 9 Feb 2017 08:42:59 -0500
Message-ID: <fa4ea104-4283-e707-019e-dee89dc66f3e@oracle.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
 <bc3bf927-568e-043a-2785-16e6c3628359@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Juergen Gross <jgross@suse.com>, wei.liu2@citrix.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 vineethp@amazon.com, xen-devel@lists.xenproject.org,
 "David S. Miller" <davem@davemloft.net>, paul.durrant@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <bc3bf927-568e-043a-2785-16e6c3628359@suse.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

CgpPbiAwMi8wMy8yMDE3IDA0OjM4IEFNLCBKdWVyZ2VuIEdyb3NzIHdyb3RlOgo+IE9uIDMwLzAx
LzE3IDE4OjQ1LCBCb3JpcyBPc3Ryb3Zza3kgd3JvdGU6Cj4+IHJ4X3JlZmlsbF90aW1lciBzaG91
bGQgYmUgZGVsZXRlZCBhcyBzb29uIGFzIHdlIGRpc2Nvbm5lY3QgZnJvbSB0aGUKPj4gYmFja2Vu
ZCBzaW5jZSBvdGhlcndpc2UgaXQgaXMgcG9zc2libGUgZm9yIHRoZSB0aW1lciB0byBnbyBvZmYg
YmVmb3JlCj4+IHdlIGdldCB0byB4ZW5uZXRfZGVzdHJveV9xdWV1ZXMoKS4gSWYgdGhpcyBoYXBw
ZW5zIHdlIG1heSBkZXJlZmVyZW5jZQo+PiBxdWV1ZS0+cnguc3Jpbmcgd2hpY2ggaXMgc2V0IHRv
IE5VTEwgaW4geGVubmV0X2Rpc2Nvbm5lY3RfYmFja2VuZCgpLgo+Pgo+PiBTaWduZWQtb2ZmLWJ5
OiBCb3JpcyBPc3Ryb3Zza3kgPGJvcmlzLm9zdHJvdnNreUBvcmFjbGUuY29tPgo+PiBDQzogc3Rh
YmxlQHZnZXIua2VybmVsLm9yZwo+Cj4gUmV2aWV3ZWQtYnk6IEp1ZXJnZW4gR3Jvc3MgPGpncm9z
c0BzdXNlLmNvbT4KCgoKRGF2aWQsCgpBcmUgeW91IGdvaW5nIHRvIHRha2UgdGhpcyB0byB5b3Vy
IHRyZWUgb3Igd291bGQgeW91IHJhdGhlciBpdCBnb2VzIHZpYSAKWGVuIHRyZWU/CgpBbmQgdGhl
IHNhbWUgcXVlc3Rpb24gZm9yCgpodHRwczovL2xpc3RzLnhlbnByb2plY3Qub3JnL2FyY2hpdmVz
L2h0bWwveGVuLWRldmVsLzIwMTctMDIvbXNnMDA2MjUuaHRtbAoKYW5kCgpodHRwczovL2xpc3Rz
LnhlbnByb2plY3Qub3JnL2FyY2hpdmVzL2h0bWwveGVuLWRldmVsLzIwMTctMDIvbXNnMDA3NTQu
aHRtbAoKCihBbmQgd2hpbGUgSSBhbSBhdCBpdCwgSSB0b29rCgpodHRwczovL2xpc3RzLnhlbnBy
b2plY3Qub3JnL2FyY2hpdmVzL2h0bWwveGVuLWRldmVsLzIwMTctMDEvbXNnMDA4MzMuaHRtbAoK
dG8gWGVuIHRyZWUsIGhvcGUgeW91IGRvbid0IG1pbmQpCgoKLWJvcmlzCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0
Clhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwK
