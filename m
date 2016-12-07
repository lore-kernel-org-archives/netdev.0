From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 10/10] virtio: enable endian checks for sparse builds
Date: Wed, 07 Dec 2016 07:25:51 +0100
Message-ID: <1481091951.4092.12.camel@sipsolutions.net>
References: <1481038106-24899-1-git-send-email-mst@redhat.com>
	<1481038106-24899-11-git-send-email-mst@redhat.com>
	(sfid-20161206_164156_647850_329465D7)
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: kvm@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
	David Airlie <airlied@linux.ie>, linux-remoteproc@vger.kernel.org,
	dri-devel@lists.freedesktop.org, virtualization@lists.linux-foundation.org,
	linux-s390@vger.kernel.org,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-scsi@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	Asias He <asias@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	linux-kbuild@vger.kernel.org, Jens Axboe <axboe@fb.com>,
	Michal Marek <mmarek@suse.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	Matt Mackall <mpm@selenic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481038106-24899-11-git-send-email-mst@redhat.com>
	(sfid-20161206_164156_647850_329465D7)
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE2LTEyLTA2IGF0IDE3OjQxICswMjAwLCBNaWNoYWVsIFMuIFRzaXJraW4gd3Jv
dGU6Cgo+IEl0IHNlZW1zIHRoYXQgdGhlcmUgc2hvdWxkIGJlIGEgYmV0dGVyIHdheSB0byBkbyBp
dCwKPiBidXQgdGhpcyB3b3JrcyB0b28uCgpJbiBzb21lIGNhc2VzIHRoZXJlIG1pZ2h0IGJlOgoK
PiAtLS0gYS9kcml2ZXJzL3MzOTAvdmlydGlvL01ha2VmaWxlCj4gKysrIGIvZHJpdmVycy9zMzkw
L3ZpcnRpby9NYWtlZmlsZQo+IEBAIC02LDYgKzYsOCBAQAo+IMKgIyBpdCB1bmRlciB0aGUgdGVy
bXMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlICh2ZXJzaW9uIDIKPiBvbmx5KQo+
IMKgIyBhcyBwdWJsaXNoZWQgYnkgdGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbi4KPiDCoAo+
ICtDRkxBR1NfdmlydGlvX2Njdy5vICs9IC1EX19DSEVDS19FTkRJQU5fXwo+ICtDRkxBR1Nfa3Zt
X3ZpcnRpby5vICs9IC1EX19DSEVDS19FTkRJQU5fXwo+IMKgczM5MC12aXJ0aW8tb2JqcyA6PSB2
aXJ0aW9fY2N3Lm8KPiDCoGlmZGVmIENPTkZJR19TMzkwX0dVRVNUX09MRF9UUkFOU1BPUlQKPiDC
oHMzOTAtdmlydGlvLW9ianMgKz0ga3ZtX3ZpcnRpby5vCgpIZXJlIHlvdSBjb3VsZCB1c2UKCmNj
ZmxhZ3MteSArPSAtRF9fQ0hFQ0tfRU5ESUFOX18KCmZvciBleGFtcGxlLCBvciBldmVuCgpzdWJk
aXItY2NmbGFncy15ICs9IC1EX19DSEVDS19FTkRJQU5fXwoKKGluIGNhc2UgYW55IHN1YmRpcnMg
ZXZlciBnZXQgYWRkZWQgaGVyZSkKCj4gLS0tIGEvZHJpdmVycy92aG9zdC9NYWtlZmlsZQo+ICsr
KyBiL2RyaXZlcnMvdmhvc3QvTWFrZWZpbGUKPiBAQCAtMSwzICsxLDQgQEAKPiArY2NmbGFncy15
IDo9IC1EX19DSEVDS19FTkRJQU5fXwoKTG9va3MgbGlrZSB5b3UgZGlkIHRoYXQgaGVyZSBhbmQg
aW4gc29tZSBvdGhlciBwbGFjZXMgdGhvdWdoIC0gc28KcGVyaGFwcyB0aGUgczM5MCBvbmUgd2Fz
IGludGVudGlvbmFsbHkgZGlmZmVyZW50PwoKPiAtLS0gYS9uZXQvcGFja2V0L01ha2VmaWxlCj4g
KysrIGIvbmV0L3BhY2tldC9NYWtlZmlsZQo+IEBAIC0yLDYgKzIsNyBAQAo+IMKgIyBNYWtlZmls
ZSBmb3IgdGhlIHBhY2tldCBBRi4KPiDCoCMKPiDCoAo+ICtjY2ZsYWdzLXkgOj0gLURfX0NIRUNL
X0VORElBTl9fCgpUZWNobmljYWxseSB0aGlzIGlzIHNsaWdodGx5IG1vcmUgdGhhbiBhZHZlcnRp
c2VkLCBidXQgSSBndWVzcyB0aGF0CnN0aWxsIG1ha2VzIHNlbnNlIGlmIGl0J3MgY2xlYW4gbm93
LgoKam9oYW5uZXMKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fClZpcnR1YWxpemF0aW9uIG1haWxpbmcgbGlzdApWaXJ0dWFsaXphdGlvbkBsaXN0cy5saW51
eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1h
bi9saXN0aW5mby92aXJ0dWFsaXphdGlvbg==
