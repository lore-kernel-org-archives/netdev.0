From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Ensure tx watchdog failures always print.
Date: Tue, 14 Jun 2011 10:41:42 -0700
Message-ID: <4DF79D56.40200@candelatech.com>
References: <1308070213-13244-1-git-send-email-greearb@candelatech.com> <20110614.133329.165803790485169225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46480 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1FNRln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 13:41:43 -0400
In-Reply-To: <20110614.133329.165803790485169225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2011 10:33 AM, David Miller wrote:
> From: greearb@candelatech.com
> Date: Tue, 14 Jun 2011 09:50:13 -0700
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> These are too important to not have some log message
>> generated.  But, keep the logic that only prints
>> a single stack dump.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> We specifically made this print out only once, and yes
> all of it.
>
> Because it spams people's logs to the point that the message
> is not useful and only scrolls out other more important
> messages.
>
> I'm not applying this, sorry.

Is it really legit for a driver to spam this message?  I hit
this due to bugs in my code that sent pkts to the wrong
driver queue, but aside from that, we rarely if ever see
the message print.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

