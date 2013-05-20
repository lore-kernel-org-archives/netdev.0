From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] e1000e: Remove duplicate assignment of default rx/tx
 ring size
Date: Tue, 21 May 2013 00:24:28 +0800
Message-ID: <20130520162428.GA18520@weiyang.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1369037707-27026-2-git-send-email-weiyang@linux.vnet.ibm.com>
 <5199EECC.8040900@gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:54733 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab3ETQYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:24:35 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 21 May 2013 13:21:59 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 764452BB0050
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:24:31 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KGONwS20185304
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:24:23 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KGOUGq011207
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:24:30 +1000
Content-Disposition: inline
In-Reply-To: <5199EECC.8040900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 02:37:16AM -0700, Jeff Kirsher wrote:
>On 05/20/2013 01:15 AM, Wei Yang wrote:
>> tx_ring/rx_ring size is assigned in function e1000_alloc_queues(), which is
>> called by e1000_sw_init() in the early stage of e1000_probe().
>>
>> This patch just remove the duplicate assignment of this default ring size
>> value.
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Reviewed-by: Da Yu Qiu <qiudayu@cn.ibm.com>
>> ---
>>  drivers/net/ethernet/intel/e1000e/netdev.c |    4 ----
>>  1 files changed, 0 insertions(+), 4 deletions(-)
>Thanks, I have added the patch to my queue for e1000e.

Thanks~

>



-- 
Richard Yang
Help you, Help me
