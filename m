From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 1/7] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Thu, 29 Oct 2009 17:53:29 +0900
Message-ID: <961aa3350910290153n70c3d982w10699ac28be63b6c@mail.gmail.com>
References: <1256719397-4258-1-git-send-email-akinobu.mita@gmail.com>
	 <20091028131141.523854cb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lothar Wassmann <LW@karo-electronics.de>,
	linux-usb@vger.kernel.org, Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	netdev@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org,
	linux-altix@sgi.com, Joerg Roedel <joerg.roedel@amd.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20091028131141.523854cb.akpm@linux-foundation.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/10/29 Andrew Morton <akpm@linux-foundation.org>:
>
> Why were these patches resent? =A0What changed?
>
> Everybody who is going to review these patches has already reviewed
> them and now they need to review them all again?

I resent the patches because the iommu-helper change was not correct
and I introduced serious bug in bitmap_find_next_zero_area()
if align_mask !=3D 0 in follow-up patch then those were dropped from
the -mm tree.

Only [PATCH 1/7] and [PATCH 2/7] have changes since the first submissio=
n of
this patch set.

* [PATCH 1/7]
- Rewrite bitmap_set() and bitmap_clear()
- Let bitmap_find_next_zero_area() check the last bit of the limit
- Add kerneldoc for bitmap_find_next_zero_area()

* [PATCH 2/7]
- Convert find_next_zero_area() to use bitmap_find_next_zero_area() cor=
rectly
  iommu-helper doesn't want to search the last bit of the limist in bit=
map

* [PATCH 3/7] - [PATCH 7/7]
- No changes
--
To unsubscribe from this list: send the line "unsubscribe sparclinux" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
