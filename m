From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.17-rc5] pcnet32:  remove incorrect pcnet32_free_ring
Date: Fri, 26 May 2006 21:33:26 -0400
Message-ID: <4477AC66.1040709@pobox.com>
References: <20060525232240.GA30918@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:24035 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964891AbWE0Bda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 21:33:30 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060525232240.GA30918@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> During a code scan for another change I discovered that this call to
> pcnet32_free_ring must be removed.  If the open fails due to a lack of
> memory all the ring structures are removed via the call to free_ring
> and a subsequent call to open will dereference a null pointer in
> pcnet32_init_ring.
> 
> Please apply to 2.6.17.
> 
> Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

applied


