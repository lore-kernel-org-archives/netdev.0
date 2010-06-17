From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Wed, 16 Jun 2010 23:24:44 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B79CBCA1E@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA1D@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'Mike Frysinger'" <vapier@gentoo.org>,
	"James Bottomley" <JBottomley@novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>
To: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'Paul Mundt'" <lethal@linux-sh.org>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1D@IRVEXCHCCR01.corp.ad.broadcom.com>
Content-Language: en-US
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
>
> Paul Mundt wrote:
>
> > If you want to have a micro-optimization for the consistent DMA
> > case, you can check dma_is_consistent(), which is part of the API and
> > will be variable on certain platform configurations (ie, some may be
> > consistent with PCI but not on other busses, etc.)
> >
> >
>
> Thanks for the tip.  I didn't know about the dma_is_consistent() API.
> I'll use this to fix it then.
>

David, why is dma_is_consistent() always returning 1 on sparc?  The
streaming DMA is not consistent.

