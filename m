From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [AF_IUCV]: Implementation of a skb backlog queue
Date: Fri, 04 May 2007 12:22:17 -0700 (PDT)
Message-ID: <20070504.122217.89039165.davem@davemloft.net>
References: <20070428.230626.79066898.davem@davemloft.net>
	<20070504094652.GA22917@de.ibm.com>
	<20070504095134.GA32153@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52334
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423053AbXEDTWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:22:31 -0400
In-Reply-To: <20070504095134.GA32153@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Pavlic <fpavlic@de.ibm.com>
Date: Fri, 4 May 2007 11:51:34 +0200

> From: Jennifer Hunt <jenhunt@us.ibm.com>
> 
> With the inital implementation we missed to implement a skb backlog
> queue . The result is that socket receive processing tossed packets.
> Since AF_IUCV connections are working synchronously it leads to 
> connection hangs. Problems with read, close and select also
> occured. 
> Using a skb backlog queue is fixing all of these problems .
> 
> Signed-off-by: Jennifer Hunt<jenhunt@us.ibm.com>
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

Applied, thanks.
