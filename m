From: Tina Johnson <tinajohnson.1234@gmail.com>
Subject: Re: [PATCH] drivers: atm: eni: Add pci_dma_mapping_error() call
Date: Tue, 11 Nov 2014 19:52:30 +0530 (IST)
Message-ID: <alpine.DEB.2.02.1411111947230.6629@Miracleworker>
References: <1415463482-8013-1-git-send-email-tinajohnson.1234@gmail.com> <20141110.153228.2187951801277440496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tinajohnson.1234@gmail.com, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141110.153228.2187951801277440496.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, 10 Nov 2014, David Miller wrote:

> The 'trouble' label assumes that it is recovering and unwinding state
> when an error occurs after the DMA buffer is successfully mapped.
>
> It unconditionally does pci_unmap_single() if 'paddr' is non-zero
> which it might be in the error case depending upon how DMA errors
> are represented on a given platform.

Sorry for the trouble and thankyou for your very helpful comment. I
will send the revised patch.
