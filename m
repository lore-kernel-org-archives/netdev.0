From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] e1000e: Use marco instead of digit for defining
 e1000_rx_desc_packet_split
Date: Tue, 21 May 2013 00:24:52 +0800
Message-ID: <20130520162452.GB18520@weiyang.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1369037707-27026-3-git-send-email-weiyang@linux.vnet.ibm.com>
 <5199EED9.4040401@gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:58020 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab3ETQZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:25:01 -0400
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 20 May 2013 21:49:11 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 4F049E004C
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 21:57:28 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KGOoCa6095226
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 21:54:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KGOs4p013903
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:24:55 +1000
Content-Disposition: inline
In-Reply-To: <5199EED9.4040401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 02:37:29AM -0700, Jeff Kirsher wrote:
>On 05/20/2013 01:15 AM, Wei Yang wrote:
>> In structure e1000_rx_desc_packet_split, the size of wb.upper.length is
>> defined by a digit. This may introduce some problem when the lenght is
>> changed.
>>
>> This patch use the marco PS_PAGE_BUFFERS for the definition. And move the
>> definition to hw.h.
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/intel/e1000e/e1000.h |    3 ---
>>  drivers/net/ethernet/intel/e1000e/hw.h    |    5 ++++-
>>  2 files changed, 4 insertions(+), 4 deletions(-)
>Thanks, I have added the patch to my queue for e1000e.
>

Thanks~


-- 
Richard Yang
Help you, Help me
