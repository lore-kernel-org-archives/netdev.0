From: Andrew Ruder <andy@aeruder.net>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Fri, 24 Jan 2014 08:15:30 -0600
Message-ID: <20140124141530.GC20804@gmail.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
 <20140124133831.GB20804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140124133831.GB20804@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 24, 2014 at 07:38:31AM -0600, Andrew Ruder wrote:
> http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg574770.html
> http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58854

Just a little further confirmation.  This appears in
__inet_lookup_established as the last four instructions before
returning.

   <+440>:       bl      <__rcu_read_unlock>
   <+444>:       sub     sp, r11, #40    ; 0x28
   <+448>:       ldr     r0, [r11, #-48] ; 0x30
   <+452>:       ldm     sp, {r4, r5, r6, r7, r8, r9, r10, r11, sp, pc}
