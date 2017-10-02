From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Date: Mon, 2 Oct 2017 07:35:54 +0200
Message-ID: <20171002053554.GA28743@kroah.com>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001220131.GA11812@eros>
 <20171001205220.10b78086@blatinox-laptop.localdomain>
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
 ecryptfs@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com,
 linux-raid@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
 intel-gvt-dev@lists.freedesktop.org, devel@acpica.org,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-integrity@vger.kernel.org, "Tobin C. Harding" <me@tobin.cc>
To: =?iso-8859-1?B?Suly6W15?= Lefaure <jeremy.lefaure@lse.epita.fr>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20171001205220.10b78086@blatinox-laptop.localdomain>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

T24gU3VuLCBPY3QgMDEsIDIwMTcgYXQgMDg6NTI6MjBQTSAtMDQwMCwgSsOpcsOpbXkgTGVmYXVy
ZSB3cm90ZToKPiBPbiBNb24sIDIgT2N0IDIwMTcgMDk6MDE6MzEgKzExMDAKPiAiVG9iaW4gQy4g
SGFyZGluZyIgPG1lQHRvYmluLmNjPiB3cm90ZToKPiAKPiA+ID4gSW4gb3JkZXIgdG8gcmVkdWNl
IHRoZSBzaXplIG9mIHRoZSBUbzogYW5kIENjOiBsaW5lcywgZWFjaCBwYXRjaCBvZiB0aGUKPiA+
ID4gc2VyaWVzIGlzIHNlbnQgb25seSB0byB0aGUgbWFpbnRhaW5lcnMgYW5kIGxpc3RzIGNvbmNl
cm5lZCBieSB0aGUgcGF0Y2guCj4gPiA+IFRoaXMgY292ZXIgbGV0dGVyIGlzIHNlbnQgdG8gZXZl
cnkgbGlzdCBjb25jZXJuZWQgYnkgdGhpcyBzZXJpZXMuICAKPiA+IAo+ID4gV2h5IGRvbid0IHlv
dSBqdXN0IHNlbmQgaW5kaXZpZHVhbCBwYXRjaGVzIGZvciBlYWNoIHN1YnN5c3RlbT8gSSdtIG5v
dCBhIG1haW50YWluZXIgYnV0IEkgZG9uJ3Qgc2VlCj4gPiBob3cgYW55IG9uZSBwZXJzb24gaXMg
Z29pbmcgdG8gYmUgYWJsZSB0byBhcHBseSB0aGlzIHdob2xlIHNlcmllcywgaXQgaXMgbWFraW5n
IGl0IGhhcmQgZm9yCj4gPiBtYWludGFpbmVycyBpZiB0aGV5IGhhdmUgdG8gcGljayBwYXRjaGVz
IG91dCBmcm9tIGFtb25nIHRoZSBzZXJpZXMgKGlmIGluZGVlZCBhbnkgd2lsbCBib3RoZXIKPiA+
IGRvaW5nIHRoYXQpLgo+IFllYWgsIG1heWJlIGl0IHdvdWxkIGhhdmUgYmVlbiBiZXR0ZXIgdG8g
c2VuZCBpbmRpdmlkdWFsIHBhdGNoZXMuCj4gCj4gRnJvbSBteSBwb2ludCBvZiB2aWV3IGl0J3Mg
YSBzZXJpZXMgYmVjYXVzZSB0aGUgcGF0Y2hlcyBhcmUgcmVsYXRlZCAoSQo+IGRpZCBhIGdpdCBm
b3JtYXQtcGF0Y2ggZnJvbSBteSBsb2NhbCBicmFuY2gpLiBCdXQgZm9yIHRoZSBtYWludGFpbmVy
cwo+IHBvaW50IG9mIHZpZXcsIHRoZXkgYXJlIGluZGl2aWR1YWwgcGF0Y2hlcy4KCkFuZCB0aGUg
bWFpbnRhaW5lcnMgdmlldyBpcyB3aGF0IG1hdHRlcnMgaGVyZSwgaWYgeW91IHdpc2ggdG8gZ2V0
IHlvdXIKcGF0Y2hlcyByZXZpZXdlZCBhbmQgYWNjZXB0ZWQuLi4KCnRoYW5rcywKCmdyZWcgay1o
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRyaS1kZXZl
bCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xp
c3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZlbAo=
