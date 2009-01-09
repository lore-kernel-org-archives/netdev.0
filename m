From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/4] lcs: convert to net_device_ops
Date: Fri, 09 Jan 2009 13:18:38 +0100
Message-ID: <4967409E.2020608@linux.vnet.ibm.com>
References: <20090109090156.422658000@de.ibm.com> <20090109090220.554541000@de.ibm.com> <20090109105447.GA2929@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com
To: Bastian Blank <bastian@waldi.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:47134 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbZAIMSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 07:18:40 -0500
In-Reply-To: <20090109105447.GA2929@wavehammer.waldi.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

good catch, thanks a lot. I will rework the complete patch set because
there is the same issue with ctcm and qeth_l3.

Frank

> On Fri, Jan 09, 2009 at 10:01:57AM +0100, frank.blaschka@de.ibm.com wrote:
>>  #ifdef CONFIG_IP_MULTICAST
>>  	if (!lcs_check_multicast_support(card))
>> -		card->dev->set_multicast_list = lcs_set_multicast_list;
>> +		lcs_netdev_ops.ndo_set_multicast_list = lcs_set_multicast_list;
> 
> This looks wrong. lcs_netdev_ops is static but this code used to set it
> up per card.
> 
> Bastian
> 


