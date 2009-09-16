From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [Patch net-next]atl1e:fix 2.6.31-git4 -- ATL1E 0000:03:00.0:
 DMA-API: device driver frees DMA
Date: Wed, 16 Sep 2009 17:31:40 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A493DE96CD7@SHEXMB-01.global.atheros.com>
References: <12530821133392-git-send-email-jie.yang@atheros.com>
 <1253092251.11643.569.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"miles.lane@gmail.com" <miles.lane@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932136AbZIPJhG@vger.kernel.org>
In-Reply-To: <1253092251.11643.569.camel@desktop>
Content-Language: zh-CN
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, September 16, 2009 5:11 PM
Daniel Walker <dwalker@fifo99.com> wrote:

> On Wed, 2009-09-16 at 14:21 +0800, jie.yang@atheros.com wrote:
> > -           pci_unmap_page(pdev, tx_buffer->dma,
> > +           if (tx_buffer->flags & ATL1E_TX_PCIMAP_SINGLE)
> > +               pci_unmap_single(pdev, tx_buffer->dma,
> > +                   tx_buffer->length, PCI_DMA_TODEVICE);
> > +           else if (tx_buffer->flags & ATL1E_TX_PCIMAP_PAGE)
> > +               pci_unmap_page(pdev, tx_buffer->dma,
>
> Could you run this through checkpatch, and fix any errors if
> find? It looks like you uses spaces for tabs in the code
> above, maybe in the other block too..
>
> Daniel
>
>

ou, my mistake, just resend.

Best  wishes
jie
