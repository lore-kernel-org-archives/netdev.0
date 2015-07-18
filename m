From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Fri, 17 Jul 2015 18:18:25 -0700 (PDT)
Message-ID: <20150717.181825.641987192390100037.davem@davemloft.net>
References: <20150717200031.GB30336@oracle.com>
	<1437174422.2495.75.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840AbbGRBFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 21:05:47 -0400
In-Reply-To: <1437174422.2495.75.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 17 Jul 2015 16:07:02 -0700

> On Fri, 2015-07-17 at 22:00 +0200, Sowmini Varadhan wrote:
>> __vxlan_find_mac invokes ether_addr_equal on the eth_addr field,
>> which triggers unaligned access messages, so rearrange vxlan_fdb
>> to avoid this in the most non-intrusive way.
> 
> What arch does this?

Sparc, MIPS, etc.
