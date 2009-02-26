From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 15:01:41 +0100
Message-ID: <49A6A0C5.60105@free.fr>
References: <49A69784.6070204@free.fr>	<20090226.052411.77955912.davem@davemloft.net>	<49A69C66.6000005@free.fr> <20090226.055138.178968734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:49307 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbZBZOBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 09:01:53 -0500
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate8.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n1QE1plb379618
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:01:51 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1QE1oXO3125448
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:01:50 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1QE1o5X004543
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 14:01:50 GMT
In-Reply-To: <20090226.055138.178968734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Daniel Lezcano <daniel.lezcano@free.fr>
> Date: Thu, 26 Feb 2009 14:43:02 +0100
>
>   
>> I was wondering if it would have make sense to remove the unloading
>> module code from ipv6 which is big at all and not testable.
>>     
>
> The majority of that code is needed anyways for the module load
> failure paths.
Right, I missed this point. I have my answer :)
 Thanks
  -- Daniel
