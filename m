From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions
 to explicitly pass FOLL_* flags
Date: Wed, 19 Oct 2016 10:23:55 -0700
Message-ID: <5807AC2B.4090208@linux.intel.com>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz> <20161019085815.GA22239@lucifer>
 <20161019090727.GE7517@dhcp22.suse.cz> <5807A427.7010200@linux.intel.com>
 <20161019170127.GN24393@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org,
 Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org, netdev@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org,
 Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org,
 Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org,
 adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Lorenzo Stoakes <lstoakes@gmail.com>,
 linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org,
 linux-fs
To: Michal Hocko <mhocko@kernel.org>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20161019170127.GN24393@dhcp22.suse.cz>
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

T24gMTAvMTkvMjAxNiAxMDowMSBBTSwgTWljaGFsIEhvY2tvIHdyb3RlOgo+IFRoZSBxdWVzdGlv
biBJIGhhZCBlYXJsaWVyIHdhcyB3aGV0aGVyIHRoaXMgaGFzIHRvIGJlIGFuIGV4cGxpY2l0IEZP
TEwKPiBmbGFnIHVzZWQgYnkgZy11LXAgdXNlcnMgb3Igd2UgY2FuIGp1c3QgdXNlIGl0IGludGVy
bmFsbHkgd2hlbiBtbSAhPQo+IGN1cnJlbnQtPm1tCgpUaGUgcmVhc29uIEkgY2hvc2Ugbm90IHRv
IGRvIHRoYXQgd2FzIHRoYXQgZGVmZXJyZWQgd29yayBnZXRzIHJ1biB1bmRlcgphIGJhc2ljYWxs
eSByYW5kb20gJ2N1cnJlbnQnLiAgSWYgd2UganVzdCB1c2UgJ21tICE9IGN1cnJlbnQtPm1tJywg
dGhlbgp0aGUgZGVmZXJyZWQgd29yayB3aWxsIHNvbWV0aW1lcyBoYXZlIHBrZXlzIGVuZm9yY2Vk
IGFuZCBzb21ldGltZXMgbm90LApiYXNpY2FsbHkgcmFuZG9tbHkuCgpXZSB3YW50IHRvIGJlIGNv
bnNpc3RlbnQgd2l0aCB3aGV0aGVyIHRoZXkgYXJlIGVuZm9yY2VkIG9yIG5vdCwgc28gd2UKZXhw
bGljaXRseSBpbmRpY2F0ZSB0aGF0IGJ5IGNhbGxpbmcgdGhlIHJlbW90ZSB2YXJpYW50IHZzLiBw
bGFpbi4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50
ZWwtZ2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBz
Oi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
