From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] s2io: don't run MSI handlers if device is offline.
Date: Thu, 24 May 2007 17:20:24 -0400
Message-ID: <46560198.9080204@pobox.com>
References: <20070522225029.GS5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-pci@atrey.karlin.mff.cuni.cz,
	netdev@vger.kernel.org,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47994 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811AbXEXVUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:20:44 -0400
In-Reply-To: <20070522225029.GS5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> Don't run any of the MSI handlers if the channel is off;
> also don't gather device statatistics. Also, netif_wake 
> not needed, per suggestions from
> Sivakumar Subramani <sivakumar.subramani@neterion.com>.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
> Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>

Why are the interrupt handlers being called at all, then?

This seems to be papering over another bug.


