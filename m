From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: resend MLD report if a link-local
 address completes DAD
Date: Fri, 28 Jun 2013 21:19:59 -0700 (PDT)
Message-ID: <20130628.211959.1334613143363314975.davem@davemloft.net>
References: <20130626220701.GA26180@order.stressinduktion.org>
	<20130627220448.GB25037@obelix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	dlstevens@us.ibm.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab3F2EUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:20:00 -0400
In-Reply-To: <20130627220448.GB25037@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 27 Jun 2013 19:04:48 -0300

> On Thu, Jun 27, 2013 at 12:07:01AM +0200, Hannes Frederic Sowa wrote:
>> RFC3590/RFC3810 specifies we should resend MLD reports as soon as a
>> valid link-local address is available.
>> 
>> We now use the valid_ll_addr_cnt to check if it is necessary to resend
>> a new report.
>> 
>> Changes since Flavio Leitner's version:
>> a) adapt for valid_ll_addr_cnt
>> b) resend first reports directly in the path and just arm the timer for
>>    mc_qrv-1 resends.
>> 
>> Reported-by: Flavio Leitner <fleitner@redhat.com>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: David Stevens <dlstevens@us.ibm.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Flavio Leitner <fbl@redhat.com>
>> ---
> 
> Looks good as well and fixes the issue I had.
> (my signed-off is there already)

Also applied, thanks.
