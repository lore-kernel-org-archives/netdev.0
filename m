From: =?UTF-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Date: Sun, 1 Oct 2017 20:52:20 -0400
Message-ID: <20171001205220.10b78086@blatinox-laptop.localdomain>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001220131.GA11812@eros>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: alsa-devel@alsa-project.org, nouveau@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, dm-devel@redhat.com,
 brcm80211-dev-list@cypress.com, devel@driverdev.osuosl.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
 amd-gfx@lists.freedesktop.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-acpi@vger.kernel.org,
 linux-video@atrey.karlin.mff.cuni.cz, intel-wired-lan@lists.osuosl.org,
 linux-media@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 ecryptfs@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-raid@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
 intel-gvt-dev@lists.freedesktop.org, devel@acpica.org,
 brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-integrity@vger.kernel.org
To: "Tobin C. Harding" <me@tobin.cc>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20171001220131.GA11812@eros>
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

T24gTW9uLCAyIE9jdCAyMDE3IDA5OjAxOjMxICsxMTAwCiJUb2JpbiBDLiBIYXJkaW5nIiA8bWVA
dG9iaW4uY2M+IHdyb3RlOgoKPiA+IEluIG9yZGVyIHRvIHJlZHVjZSB0aGUgc2l6ZSBvZiB0aGUg
VG86IGFuZCBDYzogbGluZXMsIGVhY2ggcGF0Y2ggb2YgdGhlCj4gPiBzZXJpZXMgaXMgc2VudCBv
bmx5IHRvIHRoZSBtYWludGFpbmVycyBhbmQgbGlzdHMgY29uY2VybmVkIGJ5IHRoZSBwYXRjaC4K
PiA+IFRoaXMgY292ZXIgbGV0dGVyIGlzIHNlbnQgdG8gZXZlcnkgbGlzdCBjb25jZXJuZWQgYnkg
dGhpcyBzZXJpZXMuICAKPiAKPiBXaHkgZG9uJ3QgeW91IGp1c3Qgc2VuZCBpbmRpdmlkdWFsIHBh
dGNoZXMgZm9yIGVhY2ggc3Vic3lzdGVtPyBJJ20gbm90IGEgbWFpbnRhaW5lciBidXQgSSBkb24n
dCBzZWUKPiBob3cgYW55IG9uZSBwZXJzb24gaXMgZ29pbmcgdG8gYmUgYWJsZSB0byBhcHBseSB0
aGlzIHdob2xlIHNlcmllcywgaXQgaXMgbWFraW5nIGl0IGhhcmQgZm9yCj4gbWFpbnRhaW5lcnMg
aWYgdGhleSBoYXZlIHRvIHBpY2sgcGF0Y2hlcyBvdXQgZnJvbSBhbW9uZyB0aGUgc2VyaWVzIChp
ZiBpbmRlZWQgYW55IHdpbGwgYm90aGVyCj4gZG9pbmcgdGhhdCkuClllYWgsIG1heWJlIGl0IHdv
dWxkIGhhdmUgYmVlbiBiZXR0ZXIgdG8gc2VuZCBpbmRpdmlkdWFsIHBhdGNoZXMuCgpGcm9tIG15
IHBvaW50IG9mIHZpZXcgaXQncyBhIHNlcmllcyBiZWNhdXNlIHRoZSBwYXRjaGVzIGFyZSByZWxh
dGVkIChJCmRpZCBhIGdpdCBmb3JtYXQtcGF0Y2ggZnJvbSBteSBsb2NhbCBicmFuY2gpLiBCdXQg
Zm9yIHRoZSBtYWludGFpbmVycwpwb2ludCBvZiB2aWV3LCB0aGV5IGFyZSBpbmRpdmlkdWFsIHBh
dGNoZXMuCgpBcyBlYWNoIHBhdGNoIGluIHRoaXMgc2VyaWVzIGlzIHN0YW5kYWxvbmUsIHRoZSBt
YWludGFpbmVycyBjYW4gcGljawp0aGUgcGF0Y2hlcyB0aGV5IHdhbnQgYW5kIGFwcGx5IHRoZW0g
aW5kaXZpZHVhbGx5LiBTbyB5ZWFoLCBtYXliZSBJCnNob3VsZCBoYXZlIHNlbnQgaW5kaXZpZHVh
bCBwYXRjaGVzLiBCdXQgSSBhbHNvIHdhbnRlZCB0byB0aWUgYWxsCnBhdGNoZXMgdG9nZXRoZXIg
YXMgaXQncyB0aGUgc2FtZSBjaGFuZ2UuCgpBbnl3YXksIEkgY2FuIHRlbGwgdG8gZWFjaCBtYWlu
dGFpbmVyIHRoYXQgdGhleSBjYW4gYXBwbHkgdGhlIHBhdGNoZXMKdGhleSdyZSBjb25jZXJuZWQg
YWJvdXQgYW5kIG5leHQgdGltZSBJIG1heSBzZW5kIGluZGl2aWR1YWwgcGF0Y2hlcy4KClRoYW5r
IHlvdSBmb3IgeW91ciBhbnN3ZXIsCkrDqXLDqW15Cl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCkludGVsLWdmeCBtYWlsaW5nIGxpc3QKSW50ZWwtZ2Z4QGxp
c3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2ludGVsLWdmeAo=
