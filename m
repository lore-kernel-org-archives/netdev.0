From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Thu, 04 Dec 2008 17:52:29 +0100
Message-ID: <49380ACD.1060009@hartkopp.net>
References: <20081128153317.GA3726@e-circ.dyndns.org>	<49340DAE.5060603@hartkopp.net> <20081203.155354.206786507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:63112 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbYLDQwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 11:52:36 -0500
In-Reply-To: <20081203.155354.206786507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Mon, 01 Dec 2008 17:15:42 +0100
>
>   
>> can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
>>
>>     
>
> Applied to net-2.6
>   

Thanks!

> But you are totally kidding yourself if you think that bumping
> that completely stupid date string has any meaning at all for
> userspace.
>
> You're either keeping to the API you're exporting to userspace
> or you're not.  And using a date string which userland has to
> test is just a cop-out for not breaking userspace interfaces.
>   

This fix does fortunately not break the userspace interface.

The version string is just for information and should not be used to 
determine changing userspace interfaces. Thinking about your concerns it 
may be the best approach to remove this version stuff entirely, before 
people begin to use it in any weird manner :-/

I'll make a RFC on the CAN ML if it can be removed.

Thanks for the feedback,

Oliver

