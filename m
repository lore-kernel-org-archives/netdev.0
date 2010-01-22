From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 06/11] de2104x: fix DMA sync_single length error
Date: Thu, 21 Jan 2010 17:12:09 -0800
Message-ID: <20100121171209.1e8eb864@nehalam>
References: <20100120204459.820265084@vyatta.com>
	<20100120204559.177544514@vyatta.com>
	<20100122010244.GA27529@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38313 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962Ab0AVBMV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 20:12:21 -0500
In-Reply-To: <20100122010244.GA27529@lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Jan 2010 18:02:44 -0700
Grant Grundler <grundler@parisc-linux.org> wrote:

> On Wed, Jan 20, 2010 at 12:45:05PM -0800, Stephen Hemminger wrote:
> > The DMA api requires that the full mapping be sync'd when
> > copying frame. First found by Jarek on sky2.
> 
> Are you referring to the example code in Documentation/PCI/PCI-DMA-mapping.txt?
> 
> I don't see any "Use the full mapping" statement otherwise.
> 
> Is there a DMA HW implementation that requires the syncing full buffer?
> 
> I think it would be interesting to point that out in the commit comments
> since other NIC drivers are likely to also have this issue as well.
> 
> I have no objection to this patch. Just want to be clear why
> it's being pushed.
> 
> Please added Acked-by: Grant Grundler <grundler@parisc-linux.org>

The documentation was in DMA-API.txt and it was wrong.
The DMA debug library was enforcing a bogus restriction.
Dave correctly dropped the patch.
