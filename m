From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions
 to explicitly pass FOLL_* flags
Date: Wed, 19 Oct 2016 09:58:15 +0100
Message-ID: <20161019085815.GA22239@lucifer>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org,
 Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org,
 linux-mm@kvack.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>,
 linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>,
 intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net,
 ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org,
 lin
To: Michal Hocko <mhocko@kernel.org>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20161018153050.GC13117@dhcp22.suse.cz>
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

T24gVHVlLCBPY3QgMTgsIDIwMTYgYXQgMDU6MzA6NTBQTSArMDIwMCwgTWljaGFsIEhvY2tvIHdy
b3RlOgo+IEkgYW0gd29uZGVyaW5nIHdoZXRoZXIgd2UgY2FuIGdvIGZ1cnRoZXIuIEUuZy4gaXQg
aXMgbm90IHJlYWxseSBjbGVhciB0bwo+IG1lIHdoZXRoZXIgd2UgbmVlZCBhbiBleHBsaWNpdCBG
T0xMX1JFTU9URSB3aGVuIHdlIGNhbiBpbiBmYWN0IGNoZWNrCj4gbW0gIT0gY3VycmVudC0+bW0g
YW5kIGltcGx5IHRoYXQuIE1heWJlIHRoZXJlIGFyZSBzb21lIGNvbnRleHRzIHdoaWNoCj4gd291
bGRuJ3Qgd29yaywgSSBoYXZlbid0IGNoZWNrZWQuCgpUaGlzIGZsYWcgaXMgc2V0IGV2ZW4gd2hl
biAvcHJvYy9zZWxmL21lbSBpcyB1c2VkLiBJJ3ZlIG5vdCBsb29rZWQgZGVlcGx5IGludG8KdGhp
cyBmbGFnIGJ1dCBwZXJoYXBzIGFjY2Vzc2luZyB5b3VyIG93biBtZW1vcnkgdGhpcyB3YXkgY2Fu
IGJlIGNvbnNpZGVyZWQKJ3JlbW90ZScgc2luY2UgeW91J3JlIG5vdCBhY2Nlc3NpbmcgaXQgZGly
ZWN0bHkuIE9uIHRoZSBvdGhlciBoYW5kLCBwZXJoYXBzIHRoaXMKaXMganVzdCBtaXN0YWtlbiBp
biB0aGlzIGNhc2U/Cgo+IEkgZ3Vlc3MgdGhlcmUgaXMgbW9yZSB3b3JrIGluIHRoYXQgYXJlYSBh
bmQgSSBkbyBub3Qgd2FudCB0byBpbXBvc2UgYWxsCj4gdGhhdCB3b3JrIG9uIHlvdSwgYnV0IEkg
Y291bGRuJ3QgcmVzaXN0IG9uY2UgSSBzYXcgeW91IHBsYXlpbmcgaW4gdGhhdAo+IGFyZWEgOykg
RGVmaW5pdGVseSBhIGdvb2Qgc3RhcnQhCgpUaGFua3MsIEkgYW0gbW9yZSB0aGFuIGhhcHB5IHRv
IGdvIGFzIGZhciBkb3duIHRoaXMgcmFiYml0IGhvbGUgYXMgaXMgaGVscGZ1bCwKbm8gaW1wb3Np
dGlvbiBhdCBhbGwgOikKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KSW50ZWwtZ2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Au
b3JnCmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwt
Z2Z4Cg==
