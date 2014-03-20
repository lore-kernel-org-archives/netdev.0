From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Wed, 19 Mar 2014 23:43:32 -0400 (EDT)
Message-ID: <20140319.234332.1319239349442300687.davem@davemloft.net>
References: <20140319.162053.1175830729987006835.davem@davemloft.net>
	<201403182009.s2IK9Ias021320@lab1.dls>
	<OFCDE8D1D8.B2E1BD73-ON87257CA0.007580F9-87257CA0.007580FE@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41738 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbaCTDne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 23:43:34 -0400
In-Reply-To: <OFCDE8D1D8.B2E1BD73-ON87257CA0.007580F9-87257CA0.007580FE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 19 Mar 2014 15:23:27 -0600

>>
>>> +	olen = 8; /* ND_OPT_TARGET_LL_ADDR */
>>
>>I guess this is what the variable declaration assignment was
>>meant to be used for.
> 
> There are 2 packets, neighbor solicitation (received) and
> neighbor advertisement (reply) and "olen" is initially the option length
> of the NA, a constant, for allocating its buffer. After that, the temporary
> variable "olen" is set to the variable length of the options in the
> received packet (NS) and used for processing its options.
> 
> So, it's an option length in both cases, but not the same
> value and not for the same packet, throughout.

That explains things, thanks.
