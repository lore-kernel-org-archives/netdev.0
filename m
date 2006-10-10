From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][SCTP]: Fix receive buffer accounting.
Date: Mon, 09 Oct 2006 21:34:12 -0700 (PDT)
Message-ID: <20061009.213412.75429116.davem@davemloft.net>
References: <1160440989.27455.5.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31433
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964963AbWJJEeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 00:34:13 -0400
To: sri@us.ibm.com
In-Reply-To: <1160440989.27455.5.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 09 Oct 2006 17:43:09 -0700

> [SCTP]: Fix receive buffer accounting.
> 
> When doing receiver buffer accounting, we always used skb->truesize.
> This is problematic when processing bundled DATA chunks because for
> every DATA chunk that could be small part of one large skb, we would
> charge the size of the entire skb.  The new approach is to store the
> size of the DATA chunk we are accounting for in the sctp_ulpevent
> structure and use that stored value for accounting.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied.
