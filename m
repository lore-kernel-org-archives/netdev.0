From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/5] drivers/net/ethernet/dec/tulip: Use standard
 __set_bit_le() function
Date: Wed, 13 Jun 2012 22:31:13 +0900
Message-ID: <CAC5umygutE35hVObuooWj=ADP6PZDy4cqLtxGnRtxRX8uTtGSw@mail.gmail.com>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
	<20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
	<CAC5umyj582T+9GbOYDzOAanmMcVZ-Fdxr7i-8GWf3gTSmtAKUA@mail.gmail.com>
	<20120613214157.0a5179d5358ec7f1b2646606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>,
	akpm@linux-foundation.org, bhutchings@solarflare.com,
	grundler@parisc-linux.org, arnd@arndb.de, benh@kernel.crashing.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org
To: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120613214157.0a5179d5358ec7f1b2646606@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/6/13 Takuya Yoshikawa <takuya.yoshikawa@gmail.com>:
> On Wed, 13 Jun 2012 18:43:40 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
>
>> Should this hash_table be converted from u16 hash_table[32] to
>> DECLARE_BITMAP(hash_table, 16 * 32) to ensure that it is aligned
>> on long-word boundary?
>
> I think hash_table is already long-word aligned because it is placed
> right after a pointer.

I recommend converting to proper bitmap.  Because such an implicit
assumption is easily broken by someone touching this function.
