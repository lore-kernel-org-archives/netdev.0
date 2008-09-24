From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 2/8] netfilter: xt_time gives a wrong monthday in a leap
 year
Date: Wed, 24 Sep 2008 11:29:32 +0200
Message-ID: <48DA087C.4080300@trash.net>
References: <200809222150.m8MLoaXW031860@imap1.linux-foundation.org> <20080922.190350.63489376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	kaih.luo@gmail.com, jengelh@computergmbh.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63271 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbYIXJ3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 05:29:35 -0400
In-Reply-To: <20080922.190350.63489376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Mon, 22 Sep 2008 14:50:36 -0700
> 
>> From: Kaihui Luo <kaih.luo@gmail.com>
>>
>> The function localtime_3 in xt_time.c gives a wrong monthday in a leap
>> year after 28th 2.  calculating monthday should use the array
>> days_since_leapyear[] not days_since_year[] in a leap year.
>>
>> Signed-off-by: Kaihui Luo <kaih.luo@gmail.com>
>> Acked-by: Jan Engelhardt <jengelh@computergmbh.de>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Patrick, this seems pretty straightforward so I applied it
> to net-next-2.6


Thanks Dave.

