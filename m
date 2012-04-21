From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: Adding cancellation to ensure rndis filter
 is closed
Date: Sat, 21 Apr 2012 15:38:34 -0400 (EDT)
Message-ID: <20120421.153834.2113475722956246267.davem@davemloft.net>
References: <1334831977-5553-1-git-send-email-wenqi_ma@trendmicro.com.cn>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD33BA8@TK5EX14MBXC221.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wenqi_ma@trendmicro.com.cn, netdev@vger.kernel.org,
	kys@microsoft.com
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab2DUTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 15:38:42 -0400
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DD33BA8@TK5EX14MBXC221.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 19 Apr 2012 15:18:41 +0000

>> From: Wenqi Ma [mailto:wenqi_ma@trendmicro.com.cn]
>> Sent: Thursday, April 19, 2012 6:40 AM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; Haiyang Zhang; Wenqi Ma
>> Subject: [PATCH] net/hyperv: Adding cancellation to ensure rndis filter is
>> closed
>> 
>> Although the network interface is down, the RX packets number which
>> could be observed by ifconfig may keep on increasing.
>> 
>> This is because the WORK scheduled in netvsc_set_multicast_list()
>> may be executed after netvsc_close(). That means the rndis filter
>> may be re-enabled by do_set_multicast() even if it was closed by
>> netvsc_close().
>> 
>> By canceling possible WORK before close the rndis filter, the issue
>> could be never happened.
>> 
>> Signed-off-by: Wenqi Ma <wenqi_ma@trendmicro.com.cn>
>> Reviewed-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
 ...
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
