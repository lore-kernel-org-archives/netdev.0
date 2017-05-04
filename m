From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: Re: [PATCH v1] ACPI: Switch to use generic UUID API
Date: Thu, 4 May 2017 15:14:46 +0300
Message-ID: <20170504121446.GA26032@kuha.fi.intel.com>
References: <20170504092151.88646-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org, Liam Girdwood <lgirdwood@gmail.com>,
 linux-pci@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
 Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
 Adrian Hunter <adrian.hunter@intel.com>,
 Benjamin Tissoires <benjamin.tissoires@redhat.com>,
 Joerg Roedel <joro@8bytes.org>, linux-acpi@vger.kernel.org,
 tpmdd-devel@lists.sourceforge.net, Ben Skeggs <bskeggs@redhat.com>,
 nouveau@lists.freedesktop.org, linux-mmc@vger.kernel.org,
 Zhang Rui <rui.zhang@intel.com>, Borislav Petkov <bp@suse.de>,
 Yisen Zhuang <yisen.zhuang@huawei.com>,
 Mathias Nyman <mathias.nyman@intel.com>, intel-gfx@lists.freedesktop.org,
 linux-input@vger.kernel.org, Mark Brown <broonie@kernel.org>,
 Bjorn Helgaas <bhelgaas@google.com>, Dan Williams <dan.j.williams@intel.com>,
 Mika Westerberg <mika.westerberg@linux.intel.com>,
 Felipe Balbi <balbi@kernel.org>, netdev@vger.kernel.or
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

T24gVGh1LCBNYXkgMDQsIDIwMTcgYXQgMTI6MjE6NTFQTSArMDMwMCwgQW5keSBTaGV2Y2hlbmtv
IHdyb3RlOgo+IGFjcGlfZXZhbHVhdGVfZHNtKCkgYW5kIGZyaWVuZHMgdGFrZSBhIHBvaW50ZXIg
dG8gYSByYXcgYnVmZmVyIG9mIDE2Cj4gYnl0ZXMuIEluc3RlYWQgd2UgY29udmVydCB0aGVtIHRv
IHVzZSB1dWlkX2xlIHR5cGUuIEF0IHRoZSBzYW1lIHRpbWUgd2UKPiBjb252ZXJ0IGN1cnJlbnQg
dXNlcnMuCj4gCj4gYWNwaV9zdHJfdG9fdXVpZCgpIGJlY29tZXMgdXNlbGVzcyBhZnRlciB0aGUg
Y29udmVyc2lvbiBhbmQgaXQncyBzYWZlIHRvCj4gZ2V0IHJpZCBvZiBpdC4KPiAKPiBUaGUgY29u
dmVyc2lvbiBmaXhlcyBhIHBvdGVudGlhbCBidWcgaW4gaW50MzQweF90aGVybWFsIGFzIHdlbGwg
c2luY2UKPiB3ZSBoYXZlIHRvIHVzZSBtZW1jbXAoKSBvbiBiaW5hcnkgZGF0YS4KPiAKPiBDYzog
UmFmYWVsIEouIFd5c29ja2kgPHJqd0Byand5c29ja2kubmV0Pgo+IENjOiBNaWthIFdlc3RlcmJl
cmcgPG1pa2Eud2VzdGVyYmVyZ0BsaW51eC5pbnRlbC5jb20+Cj4gQ2M6IEJvcmlzbGF2IFBldGtv
diA8YnBAc3VzZS5kZT4KPiBDYzogRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFtc0BpbnRlbC5j
b20+Cj4gQ2M6IEFtaXIgR29sZHN0ZWluIDxhbWlyNzNpbEBnbWFpbC5jb20+Cj4gQ2M6IEphcmtr
byBTYWtraW5lbiA8amFya2tvLnNha2tpbmVuQGxpbnV4LmludGVsLmNvbT4KPiBDYzogSmFuaSBO
aWt1bGEgPGphbmkubmlrdWxhQGxpbnV4LmludGVsLmNvbT4KPiBDYzogQmVuIFNrZWdncyA8YnNr
ZWdnc0ByZWRoYXQuY29tPgo+IENjOiBCZW5qYW1pbiBUaXNzb2lyZXMgPGJlbmphbWluLnRpc3Nv
aXJlc0ByZWRoYXQuY29tPgo+IENjOiBKb2VyZyBSb2VkZWwgPGpvcm9AOGJ5dGVzLm9yZz4KPiBD
YzogQWRyaWFuIEh1bnRlciA8YWRyaWFuLmh1bnRlckBpbnRlbC5jb20+Cj4gQ2M6IFlpc2VuIFpo
dWFuZyA8eWlzZW4uemh1YW5nQGh1YXdlaS5jb20+Cj4gQ2M6IEJqb3JuIEhlbGdhYXMgPGJoZWxn
YWFzQGdvb2dsZS5jb20+Cj4gQ2M6IFpoYW5nIFJ1aSA8cnVpLnpoYW5nQGludGVsLmNvbT4KPiBD
YzogRmVsaXBlIEJhbGJpIDxiYWxiaUBrZXJuZWwub3JnPgo+IENjOiBNYXRoaWFzIE55bWFuIDxt
YXRoaWFzLm55bWFuQGludGVsLmNvbT4KPiBDYzogSGVpa2tpIEtyb2dlcnVzIDxoZWlra2kua3Jv
Z2VydXNAbGludXguaW50ZWwuY29tPgo+IENjOiBMaWFtIEdpcmR3b29kIDxsZ2lyZHdvb2RAZ21h
aWwuY29tPgo+IENjOiBNYXJrIEJyb3duIDxicm9vbmllQGtlcm5lbC5vcmc+Cj4gU2lnbmVkLW9m
Zi1ieTogQW5keSBTaGV2Y2hlbmtvIDxhbmRyaXkuc2hldmNoZW5rb0BsaW51eC5pbnRlbC5jb20+
CgpPSyBieSBtZSwgRldJVzoKClJldmlld2VkLWJ5OiBIZWlra2kgS3JvZ2VydXMgPGhlaWtraS5r
cm9nZXJ1c0BsaW51eC5pbnRlbC5jb20+CgoKVGhhbmtzLAoKLS0gCmhlaWtraQpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBs
aXN0CkludGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVz
a3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
