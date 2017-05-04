From: Benjamin Tissoires <benjamin.tissoires@redhat.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Thu, 4 May 2017 17:29:01 +0200
Message-ID: <20170504152901.GA16181@mail.corp.redhat.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org,
 Heikki Krogerus <heikki.krogerus@linux.intel.com>,
 Liam Girdwood <lgirdwood@gmail.com>, linux-pci@vger.kernel.org,
 Amir Goldstein <amir73il@gmail.com>,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>, Joerg Roedel <joro@8bytes.org>,
 linux-acpi@vger.kernel.org, tpmdd-devel@lists.sourceforge.net,
 Ben Skeggs <bskeggs@redhat.com>, nouveau@lists.freedesktop.org,
 linux-mmc@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>,
 Borislav Petkov <bp@suse.de>, Yisen Zhuang <yisen.zhuang@huawei.com>,
 Mathias Nyman <mathias.nyman@intel.com>, intel-gfx@lists.freedesktop.org,
 linux-input@vger.kernel.org, Mark Brown <broonie@kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Dan Williams <dan.j.williams@intel.com>,
 Mika Westerberg <mika.westerberg@linux.intel.com>,
 Felipe Balbi <balbi@kernel.org>, netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
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

T24gTWF5IDA0IDIwMTcgb3IgdGhlcmVhYm91dHMsIEFuZHkgU2hldmNoZW5rbyB3cm90ZToKPiBh
Y3BpX2V2YWx1YXRlX2RzbSgpIGFuZCBmcmllbmRzIHRha2UgYSBwb2ludGVyIHRvIGEgcmF3IGJ1
ZmZlciBvZiAxNgo+IGJ5dGVzLiBJbnN0ZWFkIHdlIGNvbnZlcnQgdGhlbSB0byB1c2UgdXVpZF9s
ZSB0eXBlLiBBdCB0aGUgc2FtZSB0aW1lIHdlCj4gY29udmVydCBjdXJyZW50IHVzZXJzLgo+IAo+
IGFjcGlfc3RyX3RvX3V1aWQoKSBiZWNvbWVzIHVzZWxlc3MgYWZ0ZXIgdGhlIGNvbnZlcnNpb24g
YW5kIGl0J3Mgc2FmZSB0bwo+IGdldCByaWQgb2YgaXQuCj4gCj4gVGhlIGNvbnZlcnNpb24gZml4
ZXMgYSBwb3RlbnRpYWwgYnVnIGluIGludDM0MHhfdGhlcm1hbCBhcyB3ZWxsIHNpbmNlCj4gd2Ug
aGF2ZSB0byB1c2UgbWVtY21wKCkgb24gYmluYXJ5IGRhdGEuCj4gCj4gQ2M6IFJhZmFlbCBKLiBX
eXNvY2tpIDxyandAcmp3eXNvY2tpLm5ldD4KPiBDYzogTWlrYSBXZXN0ZXJiZXJnIDxtaWthLndl
c3RlcmJlcmdAbGludXguaW50ZWwuY29tPgo+IENjOiBCb3Jpc2xhdiBQZXRrb3YgPGJwQHN1c2Uu
ZGU+Cj4gQ2M6IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPgo+IENjOiBB
bWlyIEdvbGRzdGVpbiA8YW1pcjczaWxAZ21haWwuY29tPgo+IENjOiBKYXJra28gU2Fra2luZW4g
PGphcmtrby5zYWtraW5lbkBsaW51eC5pbnRlbC5jb20+Cj4gQ2M6IEphbmkgTmlrdWxhIDxqYW5p
Lm5pa3VsYUBsaW51eC5pbnRlbC5jb20+Cj4gQ2M6IEJlbiBTa2VnZ3MgPGJza2VnZ3NAcmVkaGF0
LmNvbT4KPiBDYzogQmVuamFtaW4gVGlzc29pcmVzIDxiZW5qYW1pbi50aXNzb2lyZXNAcmVkaGF0
LmNvbT4KPiBDYzogSm9lcmcgUm9lZGVsIDxqb3JvQDhieXRlcy5vcmc+Cj4gQ2M6IEFkcmlhbiBI
dW50ZXIgPGFkcmlhbi5odW50ZXJAaW50ZWwuY29tPgo+IENjOiBZaXNlbiBaaHVhbmcgPHlpc2Vu
LnpodWFuZ0BodWF3ZWkuY29tPgo+IENjOiBCam9ybiBIZWxnYWFzIDxiaGVsZ2Fhc0Bnb29nbGUu
Y29tPgo+IENjOiBaaGFuZyBSdWkgPHJ1aS56aGFuZ0BpbnRlbC5jb20+Cj4gQ2M6IEZlbGlwZSBC
YWxiaSA8YmFsYmlAa2VybmVsLm9yZz4KPiBDYzogTWF0aGlhcyBOeW1hbiA8bWF0aGlhcy5ueW1h
bkBpbnRlbC5jb20+Cj4gQ2M6IEhlaWtraSBLcm9nZXJ1cyA8aGVpa2tpLmtyb2dlcnVzQGxpbnV4
LmludGVsLmNvbT4KPiBDYzogTGlhbSBHaXJkd29vZCA8bGdpcmR3b29kQGdtYWlsLmNvbT4KPiBD
YzogTWFyayBCcm93biA8YnJvb25pZUBrZXJuZWwub3JnPgo+IFNpZ25lZC1vZmYtYnk6IEFuZHkg
U2hldmNoZW5rbyA8YW5kcml5LnNoZXZjaGVua29AbGludXguaW50ZWwuY29tPgo+IC0tLQoKRm9y
IGkyYy1oaWQ6CkFja2VkLWJ5OiBCZW5qYW1pbiBUaXNzb2lyZXMgPGJlbmphbWluLnRpc3NvaXJl
c0ByZWRoYXQuY29tPgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5v
cmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1n
ZngK
