From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 15:19:08 -0500
Message-ID: <1151439548.20252.2.camel@stevo-desktop>
References: <20060626203638.19083.71231.stgit@stevo-desktop>
	 <20060627.030920.108743110.davem@davemloft.net>
	 <1151420539.3207.29.camel@stevo-desktop>
	 <20060627.131443.104035750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:29733 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1030325AbWF0UTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 16:19:11 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060627.131443.104035750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 13:14 -0700, David Miller wrote:
> This change isn't truly atomic from a kernel standpoint either.
> 
> The new dst won't be selected by the socket until later,
> when the socket tries to send something, notices the old dst
> is obsolete, and looks up a new one.
> 
> Your code could do the same thing.
> 

For an RDMA NIC, all this logic is in HW, which is why we need the event
notification; to tell the HW to change its next hop information.



