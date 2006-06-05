From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP changes for 2.6.18
Date: Mon, 05 Jun 2006 16:58:59 -0700 (PDT)
Message-ID: <20060605.165859.104035231.davem@davemloft.net>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5761
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751015AbWFEX7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:59:01 -0400
To: shemminger@osdl.org
In-Reply-To: <20060605110331.0f058738@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 5 Jun 2006 11:03:31 -0700

> Dave, please consider adding these for the 2.6.18.

I'll pick these into my tree by extracting out the patches.
Your tree wasn't based upon the net-2.6.18 tree, so if I just
pull it into mine I'll get all the upstream changes since I
cut the net-2.6.18 which at the current time I don't want :)

BTW, it seems we now have at least 3 instances "VEGAS + stuff"
and thus the core vegas logic is duplicated that many times.
Would be nice to have some core vegas infrastructure in the
generic congestion avoidance layer at some point.
