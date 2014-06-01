From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Sun, 1 Jun 2014 10:41:29 +0800
Message-ID: <20140601024129.GA5674@richard>
References: <20140528024650.GA8602@richard>
 <20140527.231803.1411461924645076157.davem@davemloft.net>
 <20140531024654.GA12848@richard>
 <20140530.233549.1224347263965890953.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:35024 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaFAClg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 22:41:36 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 1 Jun 2014 12:41:34 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DB55B3578048
	for <netdev@vger.kernel.org>; Sun,  1 Jun 2014 12:41:32 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s512JqDu53149798
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 12:19:53 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s512fVOI025476
	for <netdev@vger.kernel.org>; Sun, 1 Jun 2014 12:41:31 +1000
Content-Disposition: inline
In-Reply-To: <20140530.233549.1224347263965890953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2014 at 11:35:49PM -0700, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Sat, 31 May 2014 10:46:54 +0800
>
>> I have back port code to 3.14, 3.10 and verified.
>> 
>> While on 3.4, this kernel version doesn't work on our latest machine.
>> This is a latest Power Machine. I don't have a spare x86 machine to verify
>> this card. And this card is in US, while I am in China.
>> 
>> Is it possible to send out the code without verification? And ask help from
>> others, like Mellanox engineer? Otherwise this would be a little trouble.
>
>Just do a best effort backport and make sure it compiles cleanly.

Got it, I will make sure it compiles on our platform.


-- 
Richard Yang
Help you, Help me
