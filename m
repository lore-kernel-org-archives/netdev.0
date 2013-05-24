From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] be2net: bug fix on returning an invalid nic descriptor
Date: Fri, 24 May 2013 10:12:18 +0800
Message-ID: <20130524021218.GA11660@weiyang.vnet.ibm.com>
References: <1369274302-8118-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20130523.185704.1417837541186108953.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, sathya.perla@emulex.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:33535 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759522Ab3EXCMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 22:12:25 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 24 May 2013 07:38:07 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 9122EE0053
	for <netdev@vger.kernel.org>; Fri, 24 May 2013 07:44:55 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4O2CEN92359730
	for <netdev@vger.kernel.org>; Fri, 24 May 2013 07:42:15 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4O2CJLl021616
	for <netdev@vger.kernel.org>; Fri, 24 May 2013 12:12:20 +1000
Content-Disposition: inline
In-Reply-To: <20130523.185704.1417837541186108953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 23, 2013 at 06:57:04PM -0700, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Thu, 23 May 2013 09:58:22 +0800
>
>> In function be_get_nic_desc(), it will go through the descriptor array
>> returned from f/w. By comparing the desc_type field, it determines whether
>> there is a nic descriptor in the array or not. In the case of no nic
>> descriptor, this function should return NULL.
>> 
>> The code may return an invalide descriptor, when there is no nic descriptor
>> in the array and the desc_count is less than MAX_RESOURCE_DESC. In this case,
>> even there is no nic descriptor, it will still return the lase descriptor
>> since the i doesn't equal to MAX_RESOURCE_DESC.
>> 
>> This patch fix this issue by returning the descriptor when find it and return
>> NULL for other cases.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Reviewed-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>
>Applied.

Got it, Thanks~

-- 
Richard Yang
Help you, Help me
