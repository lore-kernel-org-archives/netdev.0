From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Thu, 04 May 2017 12:37:27 +0300
Message-ID: <87d1bpotd4.fsf@intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Felipe Balbi <balbi@kernel.org>, Borislav Petkov <bp@suse.de>,
 Mathias Nyman <mathias.nyman@intel.com>,
 Yisen Zhuang <yisen.zhuang@huawei.com>, Joerg Roedel <joro@8bytes.org>,
 Amir Goldstein <amir73il@gmail.com>, "Rafael J . Wysocki" <rjw@rjwysocki.net>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Liam Girdwood <lgirdwood@gmail.com>,
 Benjamin Tissoires <benjamin.tissoires@redhat.com>,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 Ben Skeggs <bskeggs@redhat.com>, Mark Brown <broonie@kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Dan Williams <dan.j.williams@intel.com>,
 Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
 Mika Westerberg <mika.westerberg@linux.intel.com>,
 Zhang Rui <rui.zhang@intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
 linux-acpi@vger.kernel.org, tpmdd-devel@lists.sourceforge.net,
 intel-gfx@lists.freedesktop.org, nouveau@lists.freedesktop.org,
 linux-input@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mmc@vger.kernel.org, netdev@vger.kernel.org, linux-pci@vger.kernel.org,
 linux-usb@vger.kernel.org, alsa-devel@alsa-project.org,
 linux-kernel@vger.kernel.org
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

T24gVGh1LCAwNCBNYXkgMjAxNywgQW5keSBTaGV2Y2hlbmtvIDxhbmRyaXkuc2hldmNoZW5rb0Bs
aW51eC5pbnRlbC5jb20+IHdyb3RlOgo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9kcm0vaTkx
NS9pbnRlbF9hY3BpLmMgYi9kcml2ZXJzL2dwdS9kcm0vaTkxNS9pbnRlbF9hY3BpLmMKPiBpbmRl
eCBlYjYzOGExZTY5ZDIuLjcyYmZlNmNlYWRmOCAxMDA2NDQKPiAtLS0gYS9kcml2ZXJzL2dwdS9k
cm0vaTkxNS9pbnRlbF9hY3BpLmMKPiArKysgYi9kcml2ZXJzL2dwdS9kcm0vaTkxNS9pbnRlbF9h
Y3BpLmMKPiBAQCAtMTUsMTMgKzE1LDkgQEAgc3RhdGljIHN0cnVjdCBpbnRlbF9kc21fcHJpdiB7
Cj4gIAlhY3BpX2hhbmRsZSBkaGFuZGxlOwo+ICB9IGludGVsX2RzbV9wcml2Owo+ICAKPiAtc3Rh
dGljIGNvbnN0IHU4IGludGVsX2RzbV9ndWlkW10gPSB7Cj4gLQkweGQzLCAweDczLCAweGQ4LCAw
eDdlLAo+IC0JMHhkMCwgMHhjMiwKPiAtCTB4NGYsIDB4NGUsCj4gLQkweGE4LCAweDU0LAo+IC0J
MHgwZiwgMHgxMywgMHgxNywgMHhiMCwgMHgxYywgMHgyYwo+IC19Owo+ICtzdGF0aWMgY29uc3Qg
dXVpZF9sZSBpbnRlbF9kc21fZ3VpZCA9Cj4gKwlVVUlEX0xFKDB4N2VkODczZDMsIDB4YzJkMCwg
MHg0ZTRmLAo+ICsJCTB4YTgsIDB4NTQsIDB4MGYsIDB4MTMsIDB4MTcsIDB4YjAsIDB4MWMsIDB4
MmMpOwo+ICAKPiAgc3RhdGljIGNoYXIgKmludGVsX2RzbV9wb3J0X25hbWUodTggaWQpCj4gIHsK
PiBAQCAtODAsNyArNzYsNyBAQCBzdGF0aWMgdm9pZCBpbnRlbF9kc21fcGxhdGZvcm1fbXV4X2lu
Zm8odm9pZCkKPiAgCWludCBpOwo+ICAJdW5pb24gYWNwaV9vYmplY3QgKnBrZywgKmNvbm5lY3Rv
cl9jb3VudDsKPiAgCj4gLQlwa2cgPSBhY3BpX2V2YWx1YXRlX2RzbV90eXBlZChpbnRlbF9kc21f
cHJpdi5kaGFuZGxlLCBpbnRlbF9kc21fZ3VpZCwKPiArCXBrZyA9IGFjcGlfZXZhbHVhdGVfZHNt
X3R5cGVkKGludGVsX2RzbV9wcml2LmRoYW5kbGUsICZpbnRlbF9kc21fZ3VpZCwKPiAgCQkJSU5U
RUxfRFNNX1JFVklTSU9OX0lELCBJTlRFTF9EU01fRk5fUExBVEZPUk1fTVVYX0lORk8sCj4gIAkJ
CU5VTEwsIEFDUElfVFlQRV9QQUNLQUdFKTsKPiAgCWlmICghcGtnKSB7Cj4gQEAgLTExOCw3ICsx
MTQsNyBAQCBzdGF0aWMgYm9vbCBpbnRlbF9kc21fcGNpX3Byb2JlKHN0cnVjdCBwY2lfZGV2ICpw
ZGV2KQo+ICAJaWYgKCFkaGFuZGxlKQo+ICAJCXJldHVybiBmYWxzZTsKPiAgCj4gLQlpZiAoIWFj
cGlfY2hlY2tfZHNtKGRoYW5kbGUsIGludGVsX2RzbV9ndWlkLCBJTlRFTF9EU01fUkVWSVNJT05f
SUQsCj4gKwlpZiAoIWFjcGlfY2hlY2tfZHNtKGRoYW5kbGUsICZpbnRlbF9kc21fZ3VpZCwgSU5U
RUxfRFNNX1JFVklTSU9OX0lELAo+ICAJCQkgICAgMSA8PCBJTlRFTF9EU01fRk5fUExBVEZPUk1f
TVVYX0lORk8pKSB7Cj4gIAkJRFJNX0RFQlVHX0tNUygibm8gX0RTTSBtZXRob2QgZm9yIGludGVs
IGRldmljZVxuIik7Cj4gIAkJcmV0dXJuIGZhbHNlOwoKVGhlIGRybS9pOTE1IGh1bmsgYWJvdmUg
aXMKClJldmlld2VkLWJ5OiBKYW5pIE5pa3VsYSA8amFuaS5uaWt1bGFAaW50ZWwuY29tPgoKYW5k
IGFja2VkIGZvciBtZXJnaW5nIHZpYSB3aGljaGV2ZXIgdHJlZSBpcyBzdWl0YWJsZS4KCgpCUiwK
SmFuaS4KCi0tIApKYW5pIE5pa3VsYSwgSW50ZWwgT3BlbiBTb3VyY2UgVGVjaG5vbG9neSBDZW50
ZXIKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwt
Z2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8v
bGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
