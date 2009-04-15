From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses
 dev_addr_list
Date: Wed, 15 Apr 2009 03:15:10 -0700 (PDT)
Message-ID: <20090415.031510.162624644.davem@davemloft.net>
References: <49E5A896.90408@cosmosbay.com>
	<20090415.023104.82135803.davem@davemloft.net>
	<49E5B365.2010008@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jpirko@redhat.com, lizf@cn.fujitsu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, mschmidt@redhat.com,
	ivecera@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45300
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759588AbZDOKPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:15:19 -0400
In-Reply-To: <49E5B365.2010008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 15 Apr 2009 12:13:57 +0200

> David Miller wrote:
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Wed, 15 Apr 2009 11:27:50 +0200
>> 
>>> Since you obviously need a write lock here to be sure following
>>> can be done by one cpu only.
>>>
>>> You have same problem all over this patch.
>> RTNL semaphore is held across all modification operations.
> 
> If this will also be used for multicast lists, changes can happen
> (IPv6) without the RTNL.

Indeed, that is true :-/
