From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5][SCTP]: Extend /proc/net/sctp/snmp to provide more
 statistics.
Date: Tue, 22 Aug 2006 00:21:23 -0700 (PDT)
Message-ID: <20060822.002123.107686338.davem@davemloft.net>
References: <1155925347.20802.25.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45282
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750895AbWHVHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:21:09 -0400
To: sri@us.ibm.com
In-Reply-To: <1155925347.20802.25.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 18 Aug 2006 11:22:27 -0700

> [SCTP]: Extend /proc/net/sctp/snmp to provide more statistics.
> 
> This patch adds more statistics info under /proc/net/sctp/snmp
> that should be useful for debugging. The additional events that
> are counted now include timer expirations, retransmits, packet
> and data chunk discards.
> 
> The Data chunk discards include all the cases where a data chunk
> is discarded including high tsn, bad stream, dup tsn and the most
> useful one(out of receive buffer/rwnd).
> 
> Also moved the SCTP MIB data structures from the generic include
> directories to include/sctp/sctp.h.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
