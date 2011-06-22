From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 06:42:36 -0400
Message-ID: <4E01C71C.5060003@redhat.com>
References: <20110621225645.GD16021@Chamillionaire.breakpoint.cc>	<20110621.155816.1840729860084652508.davem@davemloft.net>	<4E01C34F.6050009@redhat.com> <20110622.033502.2198841895093553350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, fbl@redhat.com, netdev@vger.kernel.org,
	agospoda@redhat.com, nhorman@redhat.com, lwoodman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab1FVKmv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 06:42:51 -0400
In-Reply-To: <20110622.033502.2198841895093553350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/22/2011 06:35 AM, David Miller wrote:
> From: Prarit Bhargava <prarit@redhat.com>
> Date: Wed, 22 Jun 2011 06:26:23 -0400
>
>   
>> Using the netfilter xt-SYSRQ code seems to store the entered code and
>> execute it later after the system has returned to a normal state....
>> which is much too late to be useful.
>>     
> So add a feature that allows xt-SYSRQ to not queue the request
> and instead execute it immediately in softirq context.
>
> I don't see what the big deal is.
>   

I'm not familiar with the netfilter code and was about to ask some other
colleagues about it ... but I think you answered my main question which
was "does netfilter do things in interrupt context?"

P.
