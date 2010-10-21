From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 02/22] bitops: rename generic little-endian bitops functions
Date: Thu, 21 Oct 2010 17:07:16 +0200
Message-ID: <201010211707.17049.arnd@arndb.de>
References: <1287672077-5797-1-git-send-email-akinobu.mita@gmail.com> <1287672077-5797-3-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Hans-Christian Egtvedt" <hans-christian.egtvedt@atmel.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Roman Zippel <zippel@linux-m68k.org>,
	Andreas Schwab <schwab@linux-m68k.org>,
	linux-m68k@lists.linux-m68k.org, Greg Ungerer <gerg@uclinux.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org,
	Andy Grover <andy.grover@oracle.com>, rds-devel@oss.oracle.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1287672077-5797-3-git-send-email-akinobu.mita@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 October 2010, Akinobu Mita wrote:
> As a preparation for providing little-endian bitops for all architectures,
> This removes generic_ prefix from little-endian bitops function names
> in asm-generic/bitops/le.h.
> 
> s/generic_find_next_le_bit/find_next_le_bit/
> s/generic_find_next_zero_le_bit/find_next_zero_le_bit/
> s/generic_find_first_zero_le_bit/find_first_zero_le_bit/
> s/generic___test_and_set_le_bit/__test_and_set_le_bit/
> s/generic___test_and_clear_le_bit/__test_and_clear_le_bit/
> s/generic_test_le_bit/test_le_bit/
> s/generic___set_le_bit/__set_le_bit/
> s/generic___clear_le_bit/__clear_le_bit/
> s/generic_test_and_set_le_bit/test_and_set_le_bit/
> s/generic_test_and_clear_le_bit/test_and_clear_le_bit/
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Roman Zippel <zippel@linux-m68k.org>
> Cc: Andreas Schwab <schwab@linux-m68k.org>
> Cc: linux-m68k@lists.linux-m68k.org
> Cc: Greg Ungerer <gerg@uclinux.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: Andy Grover <andy.grover@oracle.com>
> Cc: rds-devel@oss.oracle.com
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: Avi Kivity <avi@redhat.com>
> Cc: Marcelo Tosatti <mtosatti@redhat.com>
> Cc: kvm@vger.kernel.org

Acked-by: Arnd Bergmann <arnd@arndb.de>
