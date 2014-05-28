From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: Preserve pci_dev_data after
 __mlx4_remove_one()
Date: Wed, 28 May 2014 10:46:50 +0800
Message-ID: <20140528024650.GA8602@richard>
References: <20140527.145403.1114311769956769966.davem@davemloft.net>
 <20140528014848.GB5830@richard>
 <20140527.193737.22275611325169063.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:33958 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaE1Cq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 22:46:56 -0400
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 28 May 2014 08:16:53 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 49BAE1258048
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:16:04 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4S2l2bm60883094
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:17:02 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4S2kptI009630
	for <netdev@vger.kernel.org>; Wed, 28 May 2014 08:16:51 +0530
Content-Disposition: inline
In-Reply-To: <20140527.193737.22275611325169063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 07:37:37PM -0700, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Wed, 28 May 2014 09:48:48 +0800
>
>> I haven't done some backporting job before, so not sure how to and which
>> attention I should pay.
>> 
>> I guess I should use this tree:
>>      git://git.kernel.org/pub/scm/linux/kernel/git/jirislaby/linux-stable.git
>> and apply it on tag v3.14.4?
>
>That is Jiri's personal tree strictly for 3.12 -stable development.
>
>The real -stable tree is at:
>
>	git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
>
>And you should make versions for the most recent tags for 3.14, 3.10, 3.4,
>and 3.2

Ok, this may take some time to verify.

Could I backport it one version by one version? Or need to send out for these
four versions at the same time?

-- 
Richard Yang
Help you, Help me
