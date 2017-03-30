From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/6] virtio: wrap find_vqs
Date: Thu, 30 Mar 2017 17:32:19 +0300
Message-ID: <20170330173146-mutt-send-email-mst@kernel.org>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
 <1490820507-8005-2-git-send-email-mst@redhat.com>
 <72f533a2-482d-1956-b0fe-254e273e1818@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>, kvm@vger.kernel.org,
 linux-remoteproc@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Bjorn Andersson <bjorn.andersson@linaro.org>,
 Gerd Hoffmann <kraxel@redhat.com>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 Herbert Xu <herbert@gondor.apana.org.au>, linux-scsi@vger.kernel.org,
 John Fastabend <john.fastabend@gmail.com>, Gonglei <arei.gonglei@huawei.com>,
 Ohad Ben-Cohen <ohad@wizery.com>, Arnd Bergmann <arnd@arndb.de>,
 Amit Shah <amit@kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>,
 virtualization@lists.linux-foundation.org,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
 linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
 "David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <72f533a2-482d-1956-b0fe-254e273e1818@redhat.com>
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

T24gVGh1LCBNYXIgMzAsIDIwMTcgYXQgMDI6MDA6MDhQTSArMDgwMCwgSmFzb24gV2FuZyB3cm90
ZToKPiAKPiAKPiBPbiAyMDE35bm0MDPmnIgzMOaXpSAwNDo0OCwgTWljaGFlbCBTLiBUc2lya2lu
IHdyb3RlOgo+ID4gV2UgYXJlIGdvaW5nIHRvIGFkZCBtb3JlIHBhcmFtZXRlcnMgdG8gZmluZF92
cXMsIGxldCdzIHdyYXAgdGhlIGNhbGwgc28KPiA+IHdlIGRvbid0IG5lZWQgdG8gdHdlYWsgYWxs
IGRyaXZlcnMgZXZlcnkgdGltZS4KPiA+IAo+ID4gU2lnbmVkLW9mZi1ieTogTWljaGFlbCBTLiBU
c2lya2luPG1zdEByZWRoYXQuY29tPgo+ID4gLS0tCj4gCj4gQSBxdWljayBnbGFuY2UgYW5kIGl0
IGxvb2tzIG9rLCBidXQgd2hhdCB0aGUgYmVuZWZpdCBvZiB0aGlzIHNlcmllcywgaXMgaXQKPiBy
ZXF1aXJlZCBieSBvdGhlciBjaGFuZ2VzPwo+IAo+IFRoYW5rcwoKWWVzIC0gdG8gYXZvaWQgdG91
Y2hpbmcgYWxsIGRldmljZXMgd2hlbiBkb2luZyB0aGUgcmVzdCBvZgp0aGUgcGF0Y2hzZXQuCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRyaS1kZXZlbCBt
YWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xpc3Rz
LmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZlbAo=
