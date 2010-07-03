From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [RESEND][PATCH] cxgb4: Use kfree_skb for skb pointers
Date: Sat, 03 Jul 2010 10:56:06 +0400
Message-ID: <4C2EDF06.1000706@kernel.org>
References: <20100701094552.GA6188@hera.kernel.org>	<20100702.222851.59693056.davem@davemloft.net>	<8A71B368A89016469F72CD08050AD334081E3D00@maui.asicdesigners.com> <20100702.234342.71126498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, dkirjanov@hera.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:46172 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775Ab0GCGzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jul 2010 02:55:22 -0400
In-Reply-To: <20100702.234342.71126498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2010 10:43 AM, David Miller wrote:
> From: "Dimitrios Michailidis"<dm@chelsio.com>
> Date: Fri, 2 Jul 2010 22:51:17 -0700
>
>>
>>> From: Denis Kirjanov<dkirjanov@hera.kernel.org>
>>> Date: Thu, 1 Jul 2010 09:45:52 +0000
>>>
>>>> Use kfree_skb for skb pointers
>>>>
>>>> Acked-by: Dimitris Michailidis<dm@chelsio.com>
>>>> Signed-off-by: Denis Kirjanov<dkirjanov@kernel.org>
>>>
>>> The code is completely different in this part of the driver now, this
>>> patch does not apply.
>>>
>>> In fact there is no reference to the string "kfree" at all in the
>>> l2t.c file of the cxgb4 driver :)
>>
>> This patch is for net-next and it should apply there, I see the wrong
>> kfree (there's only one kfree).  Denis didn't mention net-next, maybe
>> you tried to apply it to net-2.6?
>
> Yes, I did.
>
> That's why people should always indicate what tree a patch is for
> in the subject line or similar.
>
Yes, I'll be more accurate next time.

Thanks.
