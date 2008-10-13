From: Ben Greear <greearb@candelatech.com>
Subject: Re: [IPROUTE]: Fix up "ip link" help text
Date: Mon, 13 Oct 2008 09:36:06 -0700
Message-ID: <48F378F6.40301@candelatech.com>
References: <48EB7D76.7050004@trash.net>	<200810072206.03062.arekm@maven.pl>	<48EBCE59.3080401@trash.net> <20081013072129.2564130f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Arkadiusz Miskiewicz <arekm@maven.pl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37551 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbYJMQgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 12:36:23 -0400
In-Reply-To: <20081013072129.2564130f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 07 Oct 2008 23:02:17 +0200
> Patrick McHardy <kaber@trash.net> wrote:
>
>   
>> Arkadiusz Miskiewicz wrote:
>>     
>>> Runtime dependand help doesn't look sane. Help should always show all possible 
>>> options/command while trying to use unsupported option should display error 
>>> message.
>>>   
>>>       
>> That makes sense. But don't complain to me about the quality
>> of the error messages afterwards please :)
>>
>>
>>     
>
> I applied a variant of Patrick's original patch. I added text for delete, and
> avoided some code movement.  The help text should only show what is supported
> otherwise there will be user complaints.
>   
I personally dislike that.  I think the tool show should everything that 
it *could* do assuming
proper kernel, etc.  Then, if it turns out the current running kernel 
can't do that, it could just
give an error:  "This feature not supported in your current kernel.  See 
[url] for info on when
features were added to the kernel."

That way, the user can see all the possible goodness out there, and 
perhaps be inclined to upgrade
to a later kernel if that gives them a feature they'd like.

Thanks,
Ben

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


