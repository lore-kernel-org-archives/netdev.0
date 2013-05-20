From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] e1000e: Not initialize the e1000_ps_page array when
 packet-split is not used
Date: Tue, 21 May 2013 00:25:56 +0800
Message-ID: <20130520162555.GD18520@weiyang.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1369037707-27026-5-git-send-email-weiyang@linux.vnet.ibm.com>
 <5199EEFF.3070905@gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:57508 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707Ab3ETQ0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:26:02 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 21 May 2013 02:17:24 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BAC31357804E
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:25:58 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KGBh4q16777230
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:11:43 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KGPvu2002163
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:25:58 +1000
Content-Disposition: inline
In-Reply-To: <5199EEFF.3070905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 02:38:07AM -0700, Jeff Kirsher wrote:
>On 05/20/2013 01:15 AM, Wei Yang wrote:
>> When packet split is not used, those fields are still initialized and memory
>> is allocated for them.
>>
>> This patch check whether packet split is used and do the initialization base
>> on the status.
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/intel/e1000e/netdev.c |   38 ++++++++++++++-------------
>>  1 files changed, 20 insertions(+), 18 deletions(-)
>Thanks, I have added the patch to my queue for e1000e.
>

Thanks~


-- 
Richard Yang
Help you, Help me
