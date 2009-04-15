From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses dev_addr_list
Date: Wed, 15 Apr 2009 12:47:43 +0200
Message-ID: <49E5BB4F.2060607@trash.net>
References: <49E5B365.2010008@trash.net>	<20090415.031510.162624644.davem@davemloft.net>	<49E5B9BD.5070204@trash.net> <20090415.034507.208815568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jpirko@redhat.com, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, mschmidt@redhat.com,
	ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56270 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbZDOKry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:47:54 -0400
In-Reply-To: <20090415.034507.208815568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 15 Apr 2009 12:41:01 +0200
> 
>> Herbert (I think) suggested to make address list updates in softirq
>> context a two-step process, where addresses would first be added to
>> a temporary list and the final change would be done in process context
>> while holding the RTNL.
>>
>> Given the complicated mess we currently have, this would be a very
>> worthwhile change IMO.
> 
> This would break the IPV6 TAHI tests if you think we could use
> such an idea for that.
> 
> When IPV6 packets arrive that influence multicast and unicast
> address lists, the effect must be essentially immediate.  Such
> that a subsequent packet will cause the kernel the behave
> with the necessary side effects, no matter how quickly that
> next packet arrives.

I see, thanks for the explanation.

