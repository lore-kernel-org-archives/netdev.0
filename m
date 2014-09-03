From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Wed, 03 Sep 2014 13:12:56 -0400
Message-ID: <54074C18.2090207@oracle.com>
References: <20140829201809.GH14753@oracle.com>	<20140901.204715.2121922580015092507.davem@davemloft.net>	<54059BAA.1080307@oracle.com> <20140902.135902.167580446823265395.davem@davemloft.net>
Reply-To: sowmini.varadhan@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29289 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbaICRNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 13:13:04 -0400
In-Reply-To: <20140902.135902.167580446823265395.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 04:59 PM, David Miller wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Tue, 02 Sep 2014 06:27:54 -0400
>
>> when there are no more packets coming, the extra 12 microsecond
>> delay is not that big of a deal anyway.
>
> How much other work could the cpu do in those 12 microseconds?
>
> That's almost 3000 cpu cycles on a T4.
>
> I understand your argument, and the fact that there are some existing
> pieces of code doing this already, so I'll think about it some more.
>
> Thanks.
>

Maybe we should just leave out patch 2/2 for now, and only retain 1/2.
I was always somewhat ambivalent about the fudge-factor anyway,
and there are plenty of other things we can do to get better
perf- we could revisit this one afterward, if it still makes
a difference.

--Sowmini
