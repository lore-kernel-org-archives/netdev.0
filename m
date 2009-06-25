From: Sachin Sant <sachinp@in.ibm.com>
Subject: Re: [2.6.30-git21] Network Namespace test failure
Date: Thu, 25 Jun 2009 11:08:30 +0530
Message-ID: <4A430D56.5080406@in.ibm.com>
References: <4A422F1E.3050208@in.ibm.com> <20090624140056.GA11912@us.ibm.com> <4A42391A.4040802@in.ibm.com> <20090625031449.GA26767@us.ibm.com> <20090625033847.GA27181@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, serue@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:42631 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbZFYFib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 01:38:31 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n5P5cXhO008591
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 11:08:33 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P5cWcd2338866
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 11:08:32 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n5P5cVA5012709
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 15:38:32 +1000
In-Reply-To: <20090625033847.GA27181@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge E. Hallyn wrote:
> Indeed the following patch fixes it on my end.  Sachin can you give
> this one a shot?
>
> thanks,
> -serge
>
> From 7193023ad09dbc4b57909c0204c19ed93472cd9e Mon Sep 17 00:00:00 2001
> From: root <root@elm3b203.beaverton.ibm.com>
> Date: Wed, 24 Jun 2009 20:26:17 -0700
> Subject: [PATCH 1/1] veth: don't free priv->status until dev->destructor
>
> Since commit ae0e8e82205c903978a79ebf5e31c670b61fa5b4, priv->status
> has been freed at veth_close().  But that causes a NULL deref at
> veth_xmit.  This patch moves priv->status free back to the device
> destructor.
>
> Signed-off-by: Serge Hallyn <serue@us.ibm.com>
> ---
Yes this fixed the problem for me.

Thanks
-Sachin

-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------

