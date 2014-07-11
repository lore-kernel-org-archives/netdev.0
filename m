From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 1/2 V2] PCI: introduce device assignment
	interface and refactory related code
Date: Fri, 11 Jul 2014 19:13:18 +0800
Message-ID: <3EDFFF80-5793-412C-92CB-6531DA2D6DCD@gmail.com>
References: <1405057961-7234-1-git-send-email-ethan.zhao@oracle.com>
	<53BFB13E.1060505@citrix.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
Cc: "<kvm@vger.kernel.org>" <kvm@vger.kernel.org>,
	"<linux-pci@vger.kernel.org>" <linux-pci@vger.kernel.org>,
	"<e1000-devel@lists.sourceforge.net>" <e1000-devel@lists.sourceforge.net>,
	"<vaughan.cao@oracle.com>" <vaughan.cao@oracle.com>,
	"<jesse.brandeburg@intel.com>" <jesse.brandeburg@intel.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	"<linux.nics@intel.com>" <linux.nics@intel.com>,
	"<konrad.wilk@oracle.com>" <konrad.wilk@oracle.com>,
	"<gleb@kernel.org>" <gleb@kernel.org>,
	"<alex.williamson@redhat.com>" <alex.williamson@redhat.com>,
	"<bhelgaas@google.com>" <bhelgaas@google.com>,
	"<boris.ostrovsky@oracle.com>" <boris.ostrovsky@oracle.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<bruce.w.allan@intel.com>" <bruce.w.allan@intel.com>,
	"<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>,
	"<john.ronciak@intel.com>" <john.ronciak@intel.com>,
	"<pbonzini@re
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <53BFB13E.1060505@citrix.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Cgo+INTaIDIwMTTE6jfUwjExyNWjrM/Czuc1OjQxo6xEYXZpZCBWcmFiZWwgPGRhdmlkLnZyYWJl
bEBjaXRyaXguY29tPiDQtLXAo7oKPiAKPj4gT24gMTEvMDcvMTQgMDY6NTIsIEV0aGFuIFpoYW8g
d3JvdGU6Cj4+IAo+PiAtLS0gYS9kcml2ZXJzL3hlbi94ZW4tcGNpYmFjay9wY2lfc3R1Yi5jCj4+
ICsrKyBiL2RyaXZlcnMveGVuL3hlbi1wY2liYWNrL3BjaV9zdHViLmMKPj4gQEAgLTEzMyw3ICsx
MzMsNyBAQCBzdGF0aWMgdm9pZCBwY2lzdHViX2RldmljZV9yZWxlYXNlKHN0cnVjdCBrcmVmICpr
cmVmKQo+PiAgICB4ZW5fcGNpYmtfY29uZmlnX2ZyZWVfZHluX2ZpZWxkcyhkZXYpOwo+PiAgICB4
ZW5fcGNpYmtfY29uZmlnX2ZyZWVfZGV2KGRldik7Cj4+IAo+PiAtICAgIGRldi0+ZGV2X2ZsYWdz
ICY9IH5QQ0lfREVWX0ZMQUdTX0FTU0lHTkVEOwo+PiArICAgIHBjaV9zcmlvdl9kZWFzc2lnbl9k
ZXZpY2UoZGV2KTsKPj4gICAgcGNpX2Rldl9wdXQoZGV2KTsKPj4gCj4+ICAgIGtmcmVlKHBzZGV2
KTsKPj4gQEAgLTQwNCw3ICs0MDQsNyBAQCBzdGF0aWMgaW50IHBjaXN0dWJfaW5pdF9kZXZpY2Uo
c3RydWN0IHBjaV9kZXYgKmRldikKPj4gICAgZGV2X2RiZygmZGV2LT5kZXYsICJyZXNldCBkZXZp
Y2VcbiIpOwo+PiAgICB4ZW5fcGNpYmtfcmVzZXRfZGV2aWNlKGRldik7Cj4+IAo+PiAtICAgIGRl
di0+ZGV2X2ZsYWdzIHw9IFBDSV9ERVZfRkxBR1NfQVNTSUdORUQ7Cj4+ICsgICAgcGNpX3NyaW92
X2Fzc2lnbl9kZXZpY2UoZGV2KTsKPj4gICAgcmV0dXJuIDA7Cj4gCj4gWGVuJ3MgUENJIHBhc3N0
aHJvdWdoIHdvcmtzIHdpdGggYWxsIFBDSSBkZXZpY2VzIG5vdCBqdXN0IFNSLUlPViBvbmVzLAo+
IHNvIHRoZSBuYW1pbmcgb2YgdGhlIGhlbHBlcnMgaXNuJ3QgY29ycmVjdC4KeWVzLCBidXQgc28g
ZmFyLCBubyBiZXR0ZXIgbmFtZSBmb3IgaXQgLCB0aG91Z2ggdGhlIGhlbHBlcnMgd29yayBmb3Ig
YWxsIFBDSSBkZXZpY2VzLgpkbyB5b3UgaGF2ZSBhbnkgZ29vZCBzdWdnZXN0aW9uID8KClRoYW5r
cywKRXRoYW4KPiAKPiBEYXZpZAoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCk9wZW4gc291cmNlIGJ1
c2luZXNzIHByb2Nlc3MgbWFuYWdlbWVudCBzdWl0ZSBidWlsdCBvbiBKYXZhIGFuZCBFY2xpcHNl
ClR1cm4gcHJvY2Vzc2VzIGludG8gYnVzaW5lc3MgYXBwbGljYXRpb25zIHdpdGggQm9uaXRhIEJQ
TSBDb21tdW5pdHkgRWRpdGlvbgpRdWlja2x5IGNvbm5lY3QgcGVvcGxlLCBkYXRhLCBhbmQgc3lz
dGVtcyBpbnRvIG9yZ2FuaXplZCB3b3JrZmxvd3MKV2lubmVyIG9mIEJPU1NJRSwgQ09ESUUsIE9X
MiBhbmQgR2FydG5lciBhd2FyZHMKaHR0cDovL3Auc2YubmV0L3NmdS9Cb25pdGFzb2Z0Cl9fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCkUxMDAwLWRldmVsIG1h
aWxpbmcgbGlzdApFMTAwMC1kZXZlbEBsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0
cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vZTEwMDAtZGV2ZWwKVG8gbGVhcm4gbW9y
ZSBhYm91dCBJbnRlbCYjMTc0OyBFdGhlcm5ldCwgdmlzaXQgaHR0cDovL2NvbW11bml0aWVzLmlu
dGVsLmNvbS9jb21tdW5pdHkvd2lyZWQK
