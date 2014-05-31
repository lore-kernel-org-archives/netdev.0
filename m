From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Sat, 31 May 2014 10:46:54 +0800
Message-ID: <20140531024654.GA12848@richard>
References: <20140528014848.GB5830@richard>
 <20140527.193737.22275611325169063.davem@davemloft.net>
 <20140528024650.GA8602@richard>
 <20140527.231803.1411461924645076157.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:35673 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755609AbaEaCrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 22:47:04 -0400
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 31 May 2014 08:17:01 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E0E2B394005A
	for <netdev@vger.kernel.org>; Sat, 31 May 2014 08:16:57 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4V2lZlL59375680
	for <netdev@vger.kernel.org>; Sat, 31 May 2014 08:17:35 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4V2ku7t005730
	for <netdev@vger.kernel.org>; Sat, 31 May 2014 08:16:56 +0530
Content-Disposition: inline
In-Reply-To: <20140527.231803.1411461924645076157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 11:18:03PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Wed, 28 May 2014 10:46:50 +0800
>
>> Could I backport it one version by one version? Or need to send out for these
>> four versions at the same time?
>
>It's awkward for me to submit a fix for only one release, I submit a
>specific set of fixes to all relevant -stable branches at one time.

David,

I have back port code to 3.14, 3.10 and verified.

While on 3.4, this kernel version doesn't work on our latest machine.
This is a latest Power Machine. I don't have a spare x86 machine to verify
this card. And this card is in US, while I am in China.

Is it possible to send out the code without verification? And ask help from
others, like Mellanox engineer? Otherwise this would be a little trouble.

-- 
Richard Yang
Help you, Help me
