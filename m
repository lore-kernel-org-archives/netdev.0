From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] ehea: Receive SKB Aggregation
Date: Tue, 8 May 2007 13:15:27 +0100
Message-ID: <20070508121527.GA16763@infradead.org>
References: <200705081405.33742.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35918 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968019AbXEHMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 08:15:53 -0400
Content-Disposition: inline
In-Reply-To: <200705081405.33742.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 02:05:33PM +0200, Thomas Klein wrote:
> This patch enables the receive side processing to aggregate TCP packets within
> the HEA device driver. It analyses the packets already received after a
> interrupt arrived and forwards these as a chains of SKBs for the same TCP
> connection with modified header field. We have seen a lower CPU load and
> improved throughput for small numbers of parallel TCP connections.
> 
> We added a disabled module parameter to prevent disruption of normal driver
> operation.
> We currently consider this as "experimental" until further review and tests
> have been passed.
> 
> Are there any concerns about including this in the mainline driver?

So we grow yet another LRO copy in drivers?  I think someone needs to
bite the bullet and make it generic.

