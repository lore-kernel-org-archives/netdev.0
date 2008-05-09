From: Chris Snook <csnook@redhat.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Fri, 09 May 2008 14:56:21 -0400
Message-ID: <48249E55.1020300@redhat.com>
References: <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net> <20080420122631.GA4761@martell.zuzino.mipt.ru> <20080420133704.63f5cc10@osprey.hogchain.net> <20080420205500.GA4762@martell.zuzino.mipt.ru> <20080421210821.28053a92@osprey.hogchain.net> <20080425195743.2bfe66ee@osprey.hogchain.net> <20080504211507.GC1040@martell.zuzino.mipt.ru> <20080506110225.31fd61a4@osprey.hogchain.net> <20080509195149.GA4985@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Luca Tettamanti <kronos.it@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497AbYEIS6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 14:58:37 -0400
In-Reply-To: <20080509195149.GA4985@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Hmmm, there was a wonderful oops on interface stop here when the other end
> of atl1 cable was physically unplugged (but there was traffic before):
> 
> 	atl1_down
> 	atl1_clean_rx_ring
> 	swiotlb_unmap_single
> 	swiotlb_unmap_single_attrs
> 	memcpy_c
> 

Intel chip, or AMD?

-- Chris
