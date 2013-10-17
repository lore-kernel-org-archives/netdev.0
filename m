From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v4 net 0/3] sctp: Use software checksum under certain
Date: Thu, 17 Oct 2013 16:21:31 -0400
Message-ID: <526046CB.6020506@gmail.com>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com> <20131017.152634.216002495730124314.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	fan.du@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:43484 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762555Ab3JQUVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:21:35 -0400
In-Reply-To: <20131017.152634.216002495730124314.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2013 03:26 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevich@gmail.com>
> Date: Tue, 15 Oct 2013 22:01:28 -0400
>
>> There are some cards that support SCTP checksum offloading.  When using
>> these cards with IPSec or forcing IP fragmentation of SCTP traffic,
>> the checksum is computed incorrectly due to the fact that xfrm and IP/IPv6
>> fragmentation code do not know that this is SCTP traffic and do not
>> know that checksum has to be computed differently.
>>
>> To fix this, we let SCTP detect these conditions and perform software
>> checksum calculation.
>
> Series applied, thanks Vlad.
>

Hi David

Could you please queue this to stable as well.

Thanks
-vlad
