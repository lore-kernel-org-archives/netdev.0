From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH: veth: Zero timestamp in xmit path.
Date: Tue, 21 Jul 2009 13:02:02 -0700
Message-ID: <4A661EBA.7040206@candelatech.com>
References: <4A661B2F.7000608@candelatech.com> <20090721.125155.168882282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35934 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbZGUUCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 16:02:03 -0400
In-Reply-To: <20090721.125155.168882282.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2009 12:51 PM, David Miller wrote:
> From: Ben Greear<greearb@candelatech.com>
> Date: Tue, 21 Jul 2009 12:46:55 -0700
>
>> This patch zero's the timestamp before handing the packet to
>> the peer interface.  This lets the peer recalculate the rx timestamp
>> if it cares about timestamps.
>>
>> The patch is against net-next, compile tested there.  Similar patch
>> was
>> functionally tested against 2.6.31-rc3.
>>
>>
>> Signed-Off-By:  Ben Greear<greearb@candelatech.com>
>
> Oh, where to begin... sigh...
>
> The "off" and "by" in "Signed-off-by" is not capitalized.
>
> There should not be two spaces after the Signed-off-by colon, there
> should be only one.
>
> There should be a space between your name and your<>  enclosed email
> address.

I had no idea that was so important.

>
>> @@ -171,6 +171,7 @@ static int veth_xmit(struct sk_buff *skb, struct
>> net_device *dev)
>
> Your email client corrupted the patch by splitting up this line.
>
> This is all just being sloppy, and it shows a lack of care put
> into your submission.

I sent as attachment as well to help mitigate this.  If sending only
an attachment is better, I will do so next time.

> Nevertheless I'm a sucker and I fixed this all up and applied your
> patch.

As always, your forbearance is appreciated!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

