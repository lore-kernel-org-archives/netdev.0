From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25] qdisc: new rate limiter
Date: Sat, 08 Dec 2007 04:02:49 +0100
Message-ID: <475A0959.20701@trash.net>
References: <20071207162618.35715892@freepuppy.rosehill> <475A0804.1060006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbXLHDDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 22:03:25 -0500
In-Reply-To: <475A0804.1060006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Stephen Hemminger wrote:
>>
>> +struct tc_rlim_qopt
>> +{
>> +    __u32   limit;        /* fifo limit (packets) */
>> +    __u32    rate;        /* bits per sec */
>>   
>
> This seems a bit small, 512mbit is the maximum rate.

Its 4gbit of course, so I guess its enough :)

