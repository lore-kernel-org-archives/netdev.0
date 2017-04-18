From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 16/22] xen-blkfront: Make use of the new
 sg_map helper function
Date: Tue, 18 Apr 2017 09:59:09 -0600
Message-ID: <bed54c06-eb00-e682-8a50-236ebb9c1db4@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-17-git-send-email-logang@deltatee.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFD3CD7@AcuExch.aculab.com>
 <20170418142723.GA27133@char.us.oracle.com>
 <7930aa93-6106-e12f-ba76-e2771d4ec2dc@deltatee.com>
 <20170418155020.GF12001@char.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>,
 Steve Wise <swise@opengridcomputing.com>,
 "linux-nvme@lists.infradead.org" <linux-nvme@lists.infradead.org>,
 "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
 Sumit Semwal <sumit.semwal@linaro.org>,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
 xen-devel@lists.xensource.com, Sagi Grimberg <sagi@grimberg.me>,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 Matthew Wilcox <mawilcox@microsoft.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>,
 "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 "sparma
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20170418155020.GF12001@char.us.oracle.com>
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

CgpPbiAxOC8wNC8xNyAwOTo1MCBBTSwgS29ucmFkIFJ6ZXN6dXRlayBXaWxrIHdyb3RlOgo+IEkg
YW0gbm90IHN1cmUgaWYgeW91IGtub3csIGJ1dCB5b3UgY2FuIGFkZCBvbiBlYWNoIHBhdGNoIHRo
ZSByZXNwZWN0aXZlCj4gbWFpbnRhaW5lciB2aWEgJ0NDJy4gVGhhdCB3YXkgeW91IGNhbiBoYXZl
IGNlcnRhaW4gbWFpbnRhaW5lcnMgQ0NlZCBvbmx5Cj4gb24gdGhlIHN1YnN5c3RlbXMgdGhleSBj
b3Zlci4gWW91IHB1dCBpdCBhZnRlciAob3IgYmVmb3JlKSB5b3VyIFNvQiBhbmQKPiBnaXQgc2Vu
ZC1lbWFpbCBoYXBwaWxseSBwaWNrcyBpdCB1cC4KClllcywgYnV0IEkndmUgc2VlbiBzb21lIG1h
aW50YWluZXJzIGNvbXBsYWluIHdoZW4gdGhleSByZWNlaXZlIGEgcGF0Y2gKd2l0aCBubyBjb250
ZXh0IChpZS4gY292ZXIgbGV0dGVyIGFuZCBmaXJzdCBwYXRjaCkuIFNvIEkgY2hvc2UgdG8gZG8g
aXQKdGhpcyB3YXkuIEkgZXhwZWN0IGluIHRoaXMgc2l0dWF0aW9uLCBubyBtYXR0ZXIgd2hhdCB5
b3UgZG8sIHNvbWVvbmUgaXMKZ29pbmcgdG8gY29tcGxhaW4gYWJvdXQgdGhlIGFwcHJvYWNoIGNo
b3Nlbi4KClRoYW5rcyBhbnl3YXkgZm9yIHRoZSB0aXAuCgpMb2dhbgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpJbnRlbC1nZnggbWFpbGluZyBsaXN0Cklu
dGVsLWdmeEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVlZGVza3RvcC5v
cmcvbWFpbG1hbi9saXN0aW5mby9pbnRlbC1nZngK
