From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 20:49:43 +0530
Message-ID: <55F19F8F.4080407@linux.vnet.ibm.com>
References: <20150909213444.GD20544@oracle.com> <20150909.144308.360246374222280540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:58513 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbIJPSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:18:00 -0400
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 10 Sep 2015 20:47:56 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 82F1FE0058
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 20:47:18 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8AFHo0O14745654
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 20:47:51 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8AFHnV0024395
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 20:47:50 +0530
In-Reply-To: <20150909.144308.360246374222280540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2015 03:13 AM, David Miller wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Wed, 9 Sep 2015 17:34:44 -0400
>
>> So the question is- who uses IFLA_INET6_STATS/IFLA_INET6_ICMP6STATS?
>> Is this intended for some ND/ripngd etc daemon?  Doesnt seem to
>> be documented in rtnetlink(7), and couldnt find any users in glibc,
>> and google did not find any usage.
>
> It doesn't really matter who uses it, it's there forever and we
> therefore can't remove it.
>
> But what we could do is add a flag in the netlink request which
> elides the stats.  GLIBC et al. could then start setting the flag.
>

+1 for this. Had similar thought. Wanted to use a flag at the higher
  level function to avoid snmp stat walk through during i/f creation.

But above idea is better.

Other idea I had was to defer the update using work queue/completion
etc..
