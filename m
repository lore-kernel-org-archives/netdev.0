From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [AF_IUCV/IUCV]: Implementation of a skb backlog
 queue
Date: Sat, 28 Apr 2007 23:06:26 -0700 (PDT)
Message-ID: <20070428.230626.79066898.davem@davemloft.net>
References: <20070419091214.GD14586@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: fpavlic@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756230AbXD2GG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 02:06:29 -0400
In-Reply-To: <20070419091214.GD14586@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Pavlic <fpavlic@de.ibm.com>
Date: Thu, 19 Apr 2007 11:12:14 +0200

> From: Jennifer Hunt <jenhunt@us.ibm.com>
> 
> With the inital implementation we missed to implement a skb backlog
> queue . The result is that socket receive processing tossed packets.
> Since AF_IUCV connections are working synchronously it leads to 
> connection hangs. Problems with read, close and select also
> occured. 
> Using a skb backlog queue is fixing all of these problems .
> 
> Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

This won't apply cleanly because of all the sk_buff packet
buffer interface API changes in the current GIT tree.

Can you fix this up and also get a Signoff from Jennifer Hunt?

Thanks a lot!
