From: Benoit Taine <benoit.taine@lip6.fr>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Tue, 22 Jul 2014 19:12:43 +0200
Message-ID: <20140722171242.GA742@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
 <20140718162213.GC31114@tuxdriver.com>
 <20140718164340.GA24960@kroah.com>
 <1405702472.30262.1.camel@dabdike.int.hansenpartnership.com>
 <20140718181759.GB2193@kroah.com>
 <1405709421.30262.8.camel@dabdike.int.hansenpartnership.com>
 <CAErSpo7svKg0HiL=g8wWAHWUN3vs0UgCvVhvd84DM6nVDmT=FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
 linux-fbdev@vger.kernel.org,
 DRI mailing list <dri-devel@lists.freedesktop.org>,
 virtualization@lists.linux-foundation.org,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 ath5k-devel@venema.h4ckr.net, linux-acenic@sunsite.dk,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 users@rt2x00.serialmonkey.com,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 Jingoo Han <jg1.han@samsung.com>, ath10k@lists.infradead.org,
 linux-hippi@sunsite.dk, industrypack-devel@lists.sourceforge.net,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 linux-wireless <linux-wireless@vger.kernel.org>,
 "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
 MPT-FusionLinux.pdl@avagotech.com, ath9k-devel@venema.h4ckr.net,
 wil6210@qca.qualcomm.com, linux-pcmcia@lists.infradead.org,
 "John W. Lin
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CAErSpo7svKg0HiL=g8wWAHWUN3vs0UgCvVhvd84DM6nVDmT=FQ@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

T24gMjEvMDcvMjAxNCAxNzoxNiwgQmpvcm4gSGVsZ2FhcyB3cm90ZToKPiBbK2NjIEppbmdvb10K
PiAKPiBPbiBGcmksIEp1bCAxOCwgMjAxNCBhdCAxMjo1MCBQTSwgSmFtZXMgQm90dG9tbGV5Cj4g
PiBBbnl3YXksIGl0J3MgUENJIGNvZGUgLi4uIGxldCB0aGUgUENJIG1haW50YWluZXIgZGVjaWRl
LiAgSG93ZXZlciwgaWYgaGUKPiA+IGRvZXMgd2FudCB0aGlzIGRvIGl0IGFzIG9uZSBiaWcgYmFu
ZyBwYXRjaCB2aWEgZWl0aGVyIHRoZSBQQ0kgb3IgVHJpdmlhbAo+ID4gdHJlZSAobGF0dGVyIGJl
Y2F1c2UgSmnFmcOtIGhhcyBleHBlcmllbmNlIGRvaW5nIHRoaXMsIGJ1dCB0aGUgZm9ybWVyCj4g
PiBtaWdodCBiZSB1c2VmdWwgc28gdGhlIGRlY2lkZXIgZmVlbHMgdGhlIHBhaW4gLi4uKQo+IAo+
IEkgZG9uJ3QgZmVlbCBzdHJvbmdseSBlaXRoZXIgd2F5LCBzbyBJIGd1ZXNzIEknbSBPSyB3aXRo
IHRoaXMsIGFuZCBpbgo+IHRoZSBzcGlyaXQgb2YgZmVlbGluZyB0aGUgcGFpbiwgSSdtIHdpbGxp
bmcgdG8gaGFuZGxlIGl0LiAgSmluZ29vCj4gcHJvcG9zZWQgc2ltaWxhciBwYXRjaGVzLCBzbyBp
dCBtaWdodCBiZSBuaWNlIHRvIGdpdmUgaGltIHNvbWUgY3JlZGl0Lgo+IAo+IEJlbm9pdCwgaG93
IGFib3V0IGlmIHlvdSB3YWl0IHVudGlsIGFib3V0IGhhbGYtd2F5IHRocm91Z2ggdGhlIG1lcmdl
Cj4gd2luZG93IGFmdGVyIHYzLjE2IHJlbGVhc2VzLCBnZW5lcmF0ZSBhbiB1cC10by1kYXRlIHNp
bmdsZSBwYXRjaCwgYW5kCj4gcG9zdCB0aGF0PyAgVGhlbiB3ZSBjYW4gdHJ5IHRvIGdldCBpdCBp
biBiZWZvcmUgdjMuMTctcmMxIHRvIG1pbmltaXplCj4gbWVyZ2UgaGFzc2xlcy4KClN1cmUsIEkg
d2lsbCBkbyB0aGlzLgoKLS0gCkJlbm/DrnQgVGFpbmUKTWFzdGVyIGN5Y2xlIGludGVybgpSZWdh
bCBUZWFtLiBMSVA2Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCmRldmVsIG1haWxpbmcgbGlzdApkZXZlbEBsaW51eGRyaXZlcnByb2plY3Qub3JnCmh0dHA6
Ly9kcml2ZXJkZXYubGludXhkcml2ZXJwcm9qZWN0Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaXZl
cmRldi1kZXZlbAo=
