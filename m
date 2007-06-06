From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: [PATCH] Virtual ethernet tunnel
Date: Wed, 06 Jun 2007 22:38:11 +0200
Message-ID: <46671B33.60907@fr.ibm.com>
References: <4666CEAA.8010903@openvz.org> <20070606.124758.85411179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, kaber@trash.net, dev@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:47249 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbXFFUjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 16:39:04 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l56Kd3H9193042
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 20:39:03 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l56Kd3ua3121166
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 21:39:03 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l56JbeZC028055
	for <netdev@vger.kernel.org>; Wed, 6 Jun 2007 20:37:40 +0100
In-Reply-To: <20070606.124758.85411179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Pavel Emelianov <xemul@openvz.org>
> Date: Wed, 06 Jun 2007 19:11:38 +0400
>
>   
>> Veth stands for Virtual ETHernet. It is a simple tunnel driver
>> that works at the link layer and looks like a pair of ethernet
>> devices interconnected with each other.
>>     
>
> I would suggest choosing a different name.
>
> 'veth' is also the name of the virtualized ethernet device
> found on IBM machines, driven by driver/net/ibmveth.[ch]
>   
Eric Biederman proposed the name "etun" which stands for "Ethernet TUNnel".

The goal of the pair device is to pass network packets between namespaces.
That reminds me the well known "pipe" which pass data between processes.

All network devices have a name describing what they do : "eth" for 
ethernet,
"dummy" for a device doing nothing, loopback, ...

Perhaps, a name like "epipe" or "npipe", which reflects what does the 
device, is more appropriate ?

-- Daniel


