From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 12:52:26 -0700 (PDT)
Message-ID: <20061020.125226.59656580.davem@davemloft.net>
References: <20061020081857.743b5eb7@localhost.localdomain>
	<20061020.122427.55507415.davem@davemloft.net>
	<20061020122527.56292b56@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2715
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750934AbWJTTwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 15:52:25 -0400
To: shemminger@osdl.org
In-Reply-To: <20061020122527.56292b56@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 20 Oct 2006 12:25:27 -0700

> Sorry, but why should we treat out-of-tree vendor code any
> differently than out-of-tree other code.

I think what netdump was trying to do, provide a way to
requeue instead of fully drop the SKB, is quite reasonable.
Don't you think?
