From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: Problems with a PCI SMC2802W
Date: Wed, 16 Mar 2005 13:14:21 -0500
Message-ID: <4238777D.6030209@pobox.com>
References: <422F118D.8070704@voicenet.com>
	<20050309160744.GN4017@Redstar.dorchain.net>
	<20050309202718.4f94b871@veagle.suse.cz>
	<20050310021724.GD17854@ruslug.rutgers.edu>
	<42302133.2060103@voicenet.com>
	<20050310103608.GB1416@taniwha.stupidest.org>
	<20050310163007.GK17854@ruslug.rutgers.edu>
	<20050316162448.GR17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Chris Wedgwood <cw@f00f.org>,
	prism54-devel@prism54.org, Feyd <feyd@seznam.cz>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20050316162448.GR17854@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> Jeff/netdev,
> 
> If no comment is given on how we should deal with
> pci_dma_sync_single/pci_dma_sync_single_for_cpu for 2.4 I'm just going
> to put in a nasty ifdef there. Comemnts?

For 2.4, why not define pci_dma_sync_single_for_{device,cpu} as 
equivalent to pci_dma_sync_single?

	Jeff
