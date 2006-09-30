From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [SCTP]: Include sk_buff overhead while updating
 the peer's receive window.
Date: Fri, 29 Sep 2006 17:09:13 -0700 (PDT)
Message-ID: <20060929.170913.95503252.davem@davemloft.net>
References: <1159560020.29637.50.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18059
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422815AbWI3AJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:09:10 -0400
To: sri@us.ibm.com
In-Reply-To: <1159560020.29637.50.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 29 Sep 2006 13:00:20 -0700

> [SCTP]: Include sk_buff overhead while updating the peer's receive window.
> 
> Currently if the sender is sending small messages, it can cause a receiver
> to run out of receive buffer space even when the advertised receive window
> is still open and results in packet drops and retransmissions. Including
> a overhead while updating the sender's view of peer receive window will
> reduce the chances of receive buffer space overshooting the receive window.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
