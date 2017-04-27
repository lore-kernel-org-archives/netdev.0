From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH v2 01/21] scatterlist: Introduce sg_map
	helper functions
Date: Thu, 27 Apr 2017 09:44:18 -0600
Message-ID: <3b7f3aba-d609-dca7-149f-107757d63fb0@deltatee.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
 <1493144468-22493-2-git-send-email-logang@deltatee.com>
 <20170426074416.GA7936@lst.de>
 <4736d44e-bbcf-5d59-a1a9-317d0f4da847@deltatee.com>
 <20170427065338.GA20677@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dri-devel@lists.freedesktop.org, Stephen Bates <sbates@raithlin.com>,
 dm-devel@redhat.com, target-devel@vger.kernel.org,
 Sumit Semwal <sumit.semwal@linaro.org>, devel@driverdev.osuosl.org,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>, linux-scsi@vger.kernel.org,
 linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org,
 Ross Zwisler <ross.zwisler@linux.intel.com>, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 sparmaintainer@unisys.com, linux-raid@vger.kernel.org,
 Dan Williams <dan.j.williams@intel.com>, megaraidlinux.pdl@broadcom.com,
 Jens Axboe <axboe@kernel.dk>,
 "Martin K. Petersen" <martin.petersen@oracle.com>, netdev@vger.kernel.org,
 Matthew Wilcox <mawilcox@microsoft.com>, linux-mmc@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20170427065338.GA20677@lst.de>
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

CgpPbiAyNy8wNC8xNyAxMjo1MyBBTSwgQ2hyaXN0b3BoIEhlbGx3aWcgd3JvdGU6Cj4gSSB0aGlu
ayB5b3UnbGwgbmVlZCB0byBmb2xsb3cgdGhlIGV4aXN0aW5nIGttYXAgc2VtYW50aWNzIGFuZCBu
ZXZlcgo+IGZhaWwgdGhlIGlvbWVtIHZlcnNpb24gZWl0aGVyLiAgT3RoZXJ3aXNlIHlvdSdsbCBo
YXZlIGEgc3BlY2lhbCBjYXNlCj4gdGhhdCdzIGFsbW9zdCBuZXZlciB1c2VkIHRoYXQgaGFzIGEg
ZGlmZmVyZW50IGVycm9yIHBhdGguCj4KPiBBZ2Fpbiwgd3Jvbmcgd2F5LiAgU3VkZGVubHkgbWFr
aW5nIHRoaW5ncyBmYWlsIGZvciB5b3VyIHNwZWNpYWwgY2FzZQo+IHRoYXQgbm9ybWFsbHkgZG9u
J3QgZmFpbCBpcyBhIHJlY2VpcGUgZm9yIGJ1Z3MuCgpJIGRvbid0IGRpc2FncmVlIGJ1dCB0aGVz
ZSByZXN0cmljdGlvbnMgbWFrZSB0aGUgcHJvYmxlbSBpbXBvc3NpYmxlIHRvCnNvbHZlPyBJZiB0
aGVyZSBpcyBpb21lbSBiZWhpbmQgYSBwYWdlIGluIGFuIFNHTCBhbmQgc29tZW9uZSB0cmllcyB0
bwptYXAgaXQsIHdlIGVpdGhlciBoYXZlIHRvIGZhaWwgb3Igd2UgYnJlYWsgaW9tZW0gc2FmZXR5
IHdoaWNoIHdhcyB5b3VyCm9yaWdpbmFsIGNvbmNlcm4uCgpMb2dhbgoKX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50ZWwtZ2Z4IG1haWxpbmcgbGlzdApJ
bnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Au
b3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
