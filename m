From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 19:42:49 -0500
Message-ID: <454BE209.4020407@pobox.com>
References: <20061103152025.5d27bd8d@freekitty>	<454BD5FD.2030502@pobox.com> <20061103.160230.71088561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52637 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932524AbWKDAnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 19:43:02 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061103.160230.71088561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 03 Nov 2006 18:51:25 -0500
> 
>> The purpose of WOL is being able to turn on a system remotely, if it is 
>> in a power-off or sleep state.
>>
>> So, if the system is -on- and the interface is down and/or driver is 
>> unloaded, are you saying WOL is a problem somehow?
> 
> Stephen is saying that if you down an interface, it should disable
> that WoL functionality.

Many distros down the interface on poweroff, a state from which WOL is 
often used, so we don't want this.


> I guess you can argue that, like IP addresses, this WoL thing is an
> attribute of the "system".

Yeah, it's definitely a system state.  When the magic packet arrives, 
the WOL wire on the motherboard is tickled, turning the machine on.

	Jeff


