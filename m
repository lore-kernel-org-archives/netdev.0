From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv6: introduce per-interface counter for
 dad-completed ipv6 addresses
Date: Fri, 28 Jun 2013 21:19:51 -0700 (PDT)
Message-ID: <20130628.211951.2123774046375197785.davem@davemloft.net>
References: <20130626220656.GA20845@order.stressinduktion.org>
	<20130627220236.GA25037@obelix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlstevens@us.ibm.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab3F2ETw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:19:52 -0400
In-Reply-To: <20130627220236.GA25037@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 27 Jun 2013 19:02:36 -0300

> On Thu, Jun 27, 2013 at 12:06:56AM +0200, Hannes Frederic Sowa wrote:
>> To reduce the number of unnecessary router solicitations, MLDv2 and IGMPv3
>> messages we need to track the number of valid (as in non-optimistic,
>> no-dad-failed and non-tentative) link-local addresses. Therefore, this
>> patch implements a valid_ll_addr_cnt in struct inet6_dev.
>> 
>> We now only emit router solicitations if the first link-local address
>> finishes duplicate address detection.
>> 
>> The changes for MLDv2 and IGMPv3 are in a follow-up patch.
>> 
>> While there, also simplify one if statement(one minor nit I made in one
>> of my previous patches):
>> 
>> if (!...)
>> 	do();
>> else
>> 	return;
>> 
>> <<into>>
>> 
>> if (...)
>> 	return;
>> do();
>> 
>> Cc: Flavio Leitner <fbl@redhat.com>
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Cc: David Stevens <dlstevens@us.ibm.com>
>> Suggested-by: David Stevens <dlstevens@us.ibm.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
> 
> Looks good and works here.
> thanks,
> Acked-by: Flavio Leitner <fbl@redhat.com>

Applied.
