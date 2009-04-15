From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses dev_addr_list
Date: Wed, 15 Apr 2009 12:13:57 +0200
Message-ID: <49E5B365.2010008@trash.net>
References: <49E59A1C.9030108@cn.fujitsu.com>	<20090415083223.GF21342@psychotron.englab.brq.redhat.com>	<49E5A896.90408@cosmosbay.com> <20090415.023104.82135803.davem@davemloft.net>
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
Received: from stinky.trash.net ([213.144.137.162]:55506 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759384AbZDOKOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:14:09 -0400
In-Reply-To: <20090415.023104.82135803.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 15 Apr 2009 11:27:50 +0200
> 
>> Since you obviously need a write lock here to be sure following
>> can be done by one cpu only.
>>
>> You have same problem all over this patch.
> 
> RTNL semaphore is held across all modification operations.

If this will also be used for multicast lists, changes can happen
(IPv6) without the RTNL.
