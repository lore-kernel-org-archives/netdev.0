From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Mon, 16 Sep 2013 13:28:48 +0800
Message-ID: <20130916052848.GA8238@weiyang.vnet.ibm.com>
References: <1379253180-10292-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20130916.005324.187580687457026092.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, dm@chelsio.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:45992 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab3IPF3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 01:29:01 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 16 Sep 2013 15:21:19 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6D8122CE8051
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 15:28:51 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8G5CM0D14286964
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 15:12:22 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8G5SnYG016520
	for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 15:28:50 +1000
Content-Disposition: inline
In-Reply-To: <20130916.005324.187580687457026092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 12:53:24AM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Sun, 15 Sep 2013 21:53:00 +0800
>
>> When driver registration fails, we need to clean up the resources allocated
>> before. cxgb4 missed to destroy the workqueue allocated at the very beginning.
>> 
>> This patch destroies the workqueue when registration fails.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>
>Applied.

Thanks~

-- 
Richard Yang
Help you, Help me
