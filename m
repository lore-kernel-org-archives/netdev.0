From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch linux-2.6.13-rc2-gitXX 1/1] zatm: mailbox converted to
 pci_alloc_consistent()
Date: Wed, 20 Jul 2005 11:55:30 -0700 (PDT)
Message-ID: <20050720.115530.85417052.davem@davemloft.net>
References: <20050719223655.GA27724@electric-eye.fr.zoreil.com>
	<200507201507.j6KF7Buk009484@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
In-Reply-To: <200507201507.j6KF7Buk009484@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: chas@cmf.nrl.navy.mil
Subject: Re: [patch linux-2.6.13-rc2-gitXX 1/1] zatm: mailbox converted to pci_alloc_consistent() 
Date: Wed, 20 Jul 2005 11:07:12 -0400

> In message <20050719223655.GA27724@electric-eye.fr.zoreil.com>,Francois Romieu 
> writes:
> >+		mbx = pci_alloc_consistent(pdev, 2*MBX_SIZE(i), &mbx_dma);
> 
> you might want a pci_set_dma_mask(,DMA_32BIT_MASK) before you call this.

That's the default, no need.
