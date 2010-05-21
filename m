From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] net-2.6 : V2 - fix dev_get_valid_name
Date: Fri, 21 May 2010 15:10:13 +0200
Message-ID: <4BF68635.4070202@free.fr>
References: <1274299939-28132-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:55049 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab0EUNKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 09:10:23 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4LDAM5v010462
	for <netdev@vger.kernel.org>; Fri, 21 May 2010 13:10:22 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4LDAMk9495772
	for <netdev@vger.kernel.org>; Fri, 21 May 2010 14:10:22 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4LDAL5Z019148
	for <netdev@vger.kernel.org>; Fri, 21 May 2010 14:10:22 +0100
In-Reply-To: <1274299939-28132-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2010 10:12 PM, Daniel Lezcano wrote:
> the commit:
>
> commit d90310243fd750240755e217c5faa13e24f41536
> Author: Octavian Purdila<opurdila@ixiacom.com>
> Date:   Wed Nov 18 02:36:59 2009 +0000
>
>      net: device name allocation cleanups
>
> introduced a bug when there is a hash collision making impossible
> to rename a device with eth%d. This bug is very hard to reproduce
> and appears rarely.
>
> The problem is coming from we don't pass a temporary buffer to
> __dev_alloc_name but 'dev->name' which is modified by the function.
>
> A detailed explanation is here:
>
> http://marc.info/?l=linux-netdev&m=127417784011987&w=2
>
> Changelog:
>   V2 : replaced strings comparison by pointers comparison
>
> Signed-off-by: Daniel Lezcano<daniel.lezcano@free.fr>
> ---
>    

Octavian, are you ok with this patch ?
