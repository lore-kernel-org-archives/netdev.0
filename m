From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 07/16] net: Make /proc/net per network namespace
Date: Wed, 12 Sep 2007 14:12:04 +0200
Message-ID: <46E7D794.5090006@fr.ibm.com>
References: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com> <m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com> <m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com> <20070912.030211.102564635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:11353 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967698AbXILMNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:13:47 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCDkuX047548
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:13:46 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCDku12080848
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:13:46 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCDkSg023158
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 14:13:46 +0200
In-Reply-To: <20070912.030211.102564635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sat, 08 Sep 2007 15:20:36 -0600
> 
>> This patch makes /proc/net per network namespace.  It modifies the global
>> variables proc_net and proc_net_stat to be per network namespace.
>> The proc_net file helpers are modified to take a network namespace argument,
>> and all of their callers are fixed to pass &init_net for that argument.
>> This ensures that all of the /proc/net files are only visible and
>> usable in the initial network namespace until the code behind them
>> has been updated to be handle multiple network namespaces.
>>
>> Making /proc/net per namespace is necessary as at least some files
>> in /proc/net depend upon the set of network devices which is per
>> network namespace, and even more files in /proc/net have contents
>> that are relevant to a single network namespace.
>>
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> 
> Patch applied, thanks.
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

Hi Dave,

it seems the fs/proc/proc_net.c was not added to the git repository.

Regards.

	-- Daniel
