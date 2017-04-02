From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/4] ixgbe: sparc: rename the
 ARCH_WANT_RELAX_ORDER to IXGBE_ALLOW_RELAXED_ORDER
Date: Sun, 2 Apr 2017 14:49:47 +0800
Message-ID: <819bc6c1-581b-3ab9-d189-1befaaf43548@huawei.com>
References: <1491031554-19516-1-git-send-email-dingtianhong@huawei.com>
 <1491031554-19516-2-git-send-email-dingtianhong@huawei.com>
 <20170401.112603.1991545644693496714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
 alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
 jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org, robin.murphy@arm.com,
 linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170401.112603.1991545644693496714.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE3LzQvMiAyOjI2LCBEYXZpZCBNaWxsZXIgd3JvdGU6Cj4gRnJvbTogRGluZyBUaWFu
aG9uZyA8ZGluZ3RpYW5ob25nQGh1YXdlaS5jb20+Cj4gRGF0ZTogU2F0LCAxIEFwciAyMDE3IDE1
OjI1OjUxICswODAwCj4gCj4+IFRpbGwgbm93IG9ubHkgdGhlIEludGVsIGl4Z2JlIGNvdWxkIHN1
cHBvcnQgZW5hYmxlCj4+IFJlbGF4ZWQgb3JkZXJpbmcgaW4gdGhlIGRyaXZlcnMgZm9yIHNwZWNp
YWwgYXJjaGl0ZWN0dXJlLAo+PiBidXQgdGhlIEFSQ0hfV0FOVF9SRUxBWF9PUkRFUiBpcyBsb29r
cyBsaWtlIGEgZ2VuZXJhbCBuYW1lCj4+IGZvciBhbGwgYXJjaCwgc28gcmVuYW1lIHRvIGEgc3Bl
Y2lmaWMgbmFtZSBmb3IgaW50ZWwKPj4gY2FyZCBsb29rcyBtb3JlIGFwcHJvcHJpYXRlLgo+Pgo+
PiBTaWduZWQtb2ZmLWJ5OiBEaW5nIFRpYW5ob25nIDxkaW5ndGlhbmhvbmdAaHVhd2VpLmNvbT4K
PiAKPiBUaGlzIGlzIG5vdCBhIGRyaXZlciBzcGVjaWZpYyBmYWNpbGl0eS4KPiAKPiBBbnkgZHJp
dmVyIGNhbiB0ZXN0IHRoaXMgc3ltYm9sIGFuZCBhY3QgYWNjb3JkaW5nbHkuCj4gCj4gSnVzdCBi
ZWNhdXNlIElYR0JFIGlzIHRoZSBmaXJzdCBhbmQgb25seSB1c2VyLCBkb2Vzbid0IG1lYW4KPiB0
aGUgZmFjaWxpdHkgaXMgZHJpdmVyIHNwZWNpZmljLgo+IAoKVW5kZXJzdGFuZCBjbGVhcmx577yM
YnV0IHRoZSBBUkNIX1dBTlRfUkVMQVhfT1JERVIgaXMgcmVhbGx5IHRvbyBnZW5lcmljIGFuZCBz
aW1wbGUsCmNhdXNlIG11Y2ggbWlzbGVhZGluZyB0byBpbmRpY2F0ZSB0aGF0IGl0IGxvb2tzIGxp
a2UgdGhlIGhhY2sgY29kZSBmb3Igc29tZSBhcmNoaXRlY3R1cmUuCndoYXQgZG8geW91IHRoaW5r
IG9mIHRoZSBFVEhFUk5FVF9BTExPV19SRUxBWEVEX09SREVSIGluIHRoZSBkcml2ZXJzL25ldC9l
dGhlcm5ldC8qLAppdCB3aWxsIG9ubHkgYWZmZWN0IGV0aGVybmV0IGFuZCBub3Qgb25seSBmb3Ig
SXhnYmUuCgpUaGFua3MKRGluZwoKCj4gVGhhbmsgeW91Lgo+IAo+IC4KPiAKCgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVsIG1h
aWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xp
c3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
