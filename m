From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 4/5] [PATCH] qeth: rework TSO functions
Date: Mon, 16 Nov 2009 07:58:37 +0100
Message-ID: <4B00F81D.8090106@linux.vnet.ibm.com>
References: <20091112101140.882313000@de.ibm.com> <20091112101301.126320000@de.ibm.com> <20091113.203621.39740182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:54809 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZKPG6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:58:31 -0500
In-Reply-To: <20091113.203621.39740182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:
> From: frank.blaschka@de.ibm.com
> Date: Thu, 12 Nov 2009 11:11:44 +0100
> 
>> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>>
>> The maximum TSO size OSA can handle is 15 * PAGE_SIZE. This
>> patch reduces gso_max_size to this value and adds some sanity
>> checks and statistics to the TSO implementation.
>> Since only layer 3 is able to do TSO move all TSO related functions
>> to the qeth_l3 module.
>>
>> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> Please don't add sysctl knobs for getting and setting TSO enabling,
> that's what ethtool is for.
I did not add any new sysfs knobs for TSO. The old one was just moved
from the core part of the driver to the L3 discipline. I know ethtool
is the way to configure TSO and I would be happy to drop sysfs off, but
we have to keep this legacy interface because of our customers and
distributors. If you say there is no way to keep it let me know and I
will rework the patch.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


