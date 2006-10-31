From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [SCTP]: Correctly set IP id for SCTP traffic
Date: Mon, 30 Oct 2006 18:54:43 -0800 (PST)
Message-ID: <20061030.185443.45208474.davem@davemloft.net>
References: <1162258717.22597.39.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5529
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751539AbWJaCym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 21:54:42 -0500
To: sri@us.ibm.com
In-Reply-To: <1162258717.22597.39.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 30 Oct 2006 17:38:37 -0800

> [SCTP]: Correctly set IP id for SCTP traffic
> 
> Make SCTP 1-1 style and peeled-off associations behave like TCP when
> setting IP id. In both cases, we set the inet_sk(sk)->daddr and initialize
> inet_sk(sk)->id to a random value.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
