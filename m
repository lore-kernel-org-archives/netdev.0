From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [Prism54-devel] Re: Problems with a PCI SMC2802W
Date: Wed, 16 Mar 2005 10:15:44 -0800
Message-ID: <20050316181544.GB24241@taniwha.stupidest.org>
References: <422F118D.8070704@voicenet.com> <20050309160744.GN4017@Redstar.dorchain.net> <20050309202718.4f94b871@veagle.suse.cz> <20050310021724.GD17854@ruslug.rutgers.edu> <42302133.2060103@voicenet.com> <20050310103608.GB1416@taniwha.stupidest.org> <20050310163007.GK17854@ruslug.rutgers.edu> <20050316162448.GR17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        Adam K Kirchhoff <adamk@voicenet.com>, prism54-devel@prism54.org,
        Feyd <feyd@seznam.cz>
Content-Disposition: inline
In-Reply-To: <20050316162448.GR17854@ruslug.rutgers.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2005 at 11:24:48AM -0500, Luis R. Rodriguez wrote:

> If no comment is given on how we should deal with
> pci_dma_sync_single/pci_dma_sync_single_for_cpu for 2.4 I'm just
> going to put in a nasty ifdef there. Comemnts?

How about just put:

#ifndef pci_dma_sync_single_for_cpu
#define pci_dma_sync_single_for_cpu pci_dma_sync_single
#endif

In one of the prism headers?
