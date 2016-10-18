From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 01/10] mm: remove write/force parameters
 from __get_user_pages_locked()
Date: Tue, 18 Oct 2016 14:43:05 +0200
Message-ID: <20161018124305.GA29967@quack2.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-2-lstoakes@gmail.com>
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
To: Lorenzo Stoakes <lstoakes@gmail.com>
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-2-lstoakes@gmail.com>
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

T24gVGh1IDEzLTEwLTE2IDAxOjIwOjExLCBMb3JlbnpvIFN0b2FrZXMgd3JvdGU6Cj4gVGhpcyBw
YXRjaCByZW1vdmVzIHRoZSB3cml0ZSBhbmQgZm9yY2UgcGFyYW1ldGVycyBmcm9tIF9fZ2V0X3Vz
ZXJfcGFnZXNfbG9ja2VkKCkKPiB0byBtYWtlIHRoZSB1c2Ugb2YgRk9MTF9GT1JDRSBleHBsaWNp
dCBpbiBjYWxsZXJzIGFzIHVzZSBvZiB0aGlzIGZsYWcgY2FuIHJlc3VsdAo+IGluIHN1cnByaXNp
bmcgYmVoYXZpb3VyIChhbmQgaGVuY2UgYnVncykgd2l0aGluIHRoZSBtbSBzdWJzeXN0ZW0uCj4g
Cj4gU2lnbmVkLW9mZi1ieTogTG9yZW56byBTdG9ha2VzIDxsc3RvYWtlc0BnbWFpbC5jb20+CgpM
b29rcyBnb29kLiBZb3UgY2FuIGFkZDoKClJldmlld2VkLWJ5OiBKYW4gS2FyYSA8amFja0BzdXNl
LmN6PgoKCQkJCQkJCQlIb256YQotLSAKSmFuIEthcmEgPGphY2tAc3VzZS5jb20+ClNVU0UgTGFi
cywgQ1IKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KSW50
ZWwtZ2Z4IG1haWxpbmcgbGlzdApJbnRlbC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnCmh0dHBz
Oi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vaW50ZWwtZ2Z4Cg==
