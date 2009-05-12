From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] powerpc: add memory map support to Freescale
	RapidIO block
Date: Tue, 12 May 2009 15:05:52 -0700
Message-ID: <20090512150552.a98dca64.akpm@linux-foundation.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	<1242117363-14949-2-git-send-email-leoli@freescale.com>
	<1242117363-14949-3-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: zw@zh-kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, leoli@freescale.com, davem@davemloft.net
To: Li Yang <leoli@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <1242117363-14949-3-git-send-email-leoli@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 12 May 2009 16:36:00 +0800
Li Yang <leoli@freescale.com> wrote:

> +	align = (size < 0x1000) ? 0x1000 : 1 << (__ilog2(size - 1) + 1);
> +
> +	/* Align the size */
> +	if ((lstart + size) > (_ALIGN_DOWN(lstart, align) + align)) {

__ilog2() and _ALIGN_DOWN() are powerpc-specific functions.  It would
be preferable to use more general helpers if possible.  ALIGN() and ilog2()
might suit here.
