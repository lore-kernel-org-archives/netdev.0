From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] cxgb4: remove workqueue when driver registration fails
Date: Sun, 15 Sep 2013 20:24:30 +0800
Message-ID: <20130915122243.GA6272@weiyang.vnet.ibm.com>
References: <1378431145-7203-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20130911.155200.1385893449933655541.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, dm@chelsio.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:53902 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab3IOMYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Sep 2013 08:24:40 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 15 Sep 2013 17:44:44 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E1846E0055
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 17:55:27 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8FCQZ2l44433562
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 17:56:35 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8FCOWcJ013890
	for <netdev@vger.kernel.org>; Sun, 15 Sep 2013 17:54:32 +0530
Content-Disposition: inline
In-Reply-To: <20130911.155200.1385893449933655541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 03:52:00PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Fri,  6 Sep 2013 09:32:25 +0800
>
>> When driver registration fails, we need to clean up the resources allocated
>> before. cxgb4 missed to destroy the workqueue allocated at the very beginning.
>> 
>> This patch destroies the workqueue when registration fails.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>
>This patch was corrupted by your email client, please email the patch
>to yourself, make sure the patch you receive in the email applies
>cleanly to the current 'net' tree, and then resubmit.

Sorry for this bothering. 

I will re-do it.

Thanks.

>
>Thanks.

-- 
Richard Yang
Help you, Help me
