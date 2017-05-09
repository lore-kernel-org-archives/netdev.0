From: Mathias Nyman <mathias.nyman@linux.intel.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Tue, 9 May 2017 11:22:55 +0300
Message-ID: <59117C5F.1080007@linux.intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: Felipe Balbi <balbi@kernel.org>,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 Mathias Nyman <mathias.nyman@intel.com>,
 Yisen Zhuang <yisen.zhuang@huawei.com>, Joerg Roedel <joro@8bytes.org>,
 Amir Goldstein <amir73il@gmail.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Liam Girdwood <lgirdwood@gmail.com>,
 Benjamin Tissoires <benjamin.tissoires@redhat.com>,
 Mark Brown <broonie@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>,
 Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@suse.de>,
 Mika Westerberg <mika.westerberg@linux.intel.com>,
 Zhang Rui <rui.zhang@intel.com>, Ben Skeggs <bskeggs@redhat.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
 linux-acpi@vger.kernel.org, tpmdd-devel@lists.sourceforge.net,
 intel-gfx@lists.freedesktop.org, nouveau@lists.freedesktop.org,
 linux-input@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mmc@vger.kernel.org, netdev@vger.kernel.org,
 linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-kernel@vger.kernel.org
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

Cj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvdXNiL2hvc3QveGhjaS1wY2kuYyBiL2RyaXZlcnMvdXNi
L2hvc3QveGhjaS1wY2kuYwo+IGluZGV4IDdiODY1MDhhYzhjZi4uOTNiNGYwZGU5NDE4IDEwMDY0
NAo+IC0tLSBhL2RyaXZlcnMvdXNiL2hvc3QveGhjaS1wY2kuYwo+ICsrKyBiL2RyaXZlcnMvdXNi
L2hvc3QveGhjaS1wY2kuYwo+IEBAIC0yMTAsMTMgKzIxMCwxMiBAQCBzdGF0aWMgdm9pZCB4aGNp
X3BjaV9xdWlya3Moc3RydWN0IGRldmljZSAqZGV2LCBzdHJ1Y3QgeGhjaV9oY2QgKnhoY2kpCj4g
ICAjaWZkZWYgQ09ORklHX0FDUEkKPiAgIHN0YXRpYyB2b2lkIHhoY2lfcG1lX2FjcGlfcnRkM19l
bmFibGUoc3RydWN0IHBjaV9kZXYgKmRldikKPiAgIHsKPiAtCXN0YXRpYyBjb25zdCB1OCBpbnRl
bF9kc21fdXVpZFtdID0gewo+IC0JCTB4YjcsIDB4MGMsIDB4MzQsIDB4YWMsCTB4MDEsIDB4ZTks
IDB4YmYsIDB4NDUsCj4gLQkJMHhiNywgMHhlNiwgMHgyYiwgMHgzNCwgMHhlYywgMHg5MywgMHgx
ZSwgMHgyMywKPiAtCX07Cj4gKwlzdGF0aWMgY29uc3QgdXVpZF9sZSBpbnRlbF9kc21fdXVpZCA9
Cj4gKwkJVVVJRF9MRSgweGFjMzQwY2I3LCAweGU5MDEsIDB4NDViZiwKPiArCQkJMHhiNywgMHhl
NiwgMHgyYiwgMHgzNCwgMHhlYywgMHg5MywgMHgxZSwgMHgyMyk7Cj4gICAJdW5pb24gYWNwaV9v
YmplY3QgKm9iajsKPgo+IC0Jb2JqID0gYWNwaV9ldmFsdWF0ZV9kc20oQUNQSV9IQU5ETEUoJmRl
di0+ZGV2KSwgaW50ZWxfZHNtX3V1aWQsIDMsIDEsCj4gKwlvYmogPSBhY3BpX2V2YWx1YXRlX2Rz
bShBQ1BJX0hBTkRMRSgmZGV2LT5kZXYpLCAmaW50ZWxfZHNtX3V1aWQsIDMsIDEsCj4gICAJCQkJ
TlVMTCk7Cj4gICAJQUNQSV9GUkVFKG9iaik7Cj4gICB9CgpGb3IgdGhlIHhoY2kgcGFydCBhYm92
ZToKCkFja2VkLWJ5OiBNYXRoaWFzIE55bWFuIDxtYXRoaWFzLm55bWFuQGxpbnV4LmludGVsLmNv
bT4KCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRl
bC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6
Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
