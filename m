From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] e1000e: Calculate the desc_len based on adapter type
Date: Tue, 21 May 2013 00:25:29 +0800
Message-ID: <20130520162529.GC18520@weiyang.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1369037707-27026-4-git-send-email-weiyang@linux.vnet.ibm.com>
 <5199EEEC.5030105@gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:54781 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753Ab3ETQZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 12:25:36 -0400
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 21 May 2013 13:23:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id CDD7F2CE804A
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:25:31 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KGBPMa23593074
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:11:25 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KGPVtC018956
	for <netdev@vger.kernel.org>; Tue, 21 May 2013 02:25:31 +1000
Content-Disposition: inline
In-Reply-To: <5199EEEC.5030105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 20, 2013 at 02:37:48AM -0700, Jeff Kirsher wrote:
>On 05/20/2013 01:15 AM, Wei Yang wrote:
>> desc_len represents the size of descriptor in rx_ring. There are two kinds of
>> rx descriptors, e1000_rx_desc_packet_split(32 byte) and
>> e1000_rx_desc_extended(16 byte). Different adapter will use different rx
>> descriptors.
>>
>> When allocating the dma space for this descriptor in current implementation,
>> the code ignore the descriptor type and take it as e1000_rx_desc_packet_split
>> in any case. This behavior will not effect the function, but will require
>> double size of dma space.
>>
>> This patch will calculate the desc_len based on the adapter type.
>>
>> Tested on T420, which use e1000_rx_desc_extended and works fine.
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/intel/e1000e/netdev.c |    7 ++++++-
>>  1 files changed, 6 insertions(+), 1 deletions(-)
>Thanks, I have added the patch to my queue for e1000e.
>

Thanks~



-- 
Richard Yang
Help you, Help me
