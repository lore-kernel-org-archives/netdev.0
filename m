From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 08:19:33 -0400
Message-ID: <4E01DDD5.8020707@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net> <4E01C34F.6050009@redhat.com> <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com, john.haxby@oracle.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924Ab1FVMTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 08:19:44 -0400
In-Reply-To: <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/22/2011 06:54 AM, Florian Westphal wrote:
> Prarit Bhargava <prarit@redhat.com> wrote:
>
> [ cc'd John Haxby, who worked on xt_SYSREQ ]
>
>   
>> On 06/21/2011 06:58 PM, David Miller wrote:
>>     
>>> From: Florian Westphal <fw@strlen.de>
>>> Date: Wed, 22 Jun 2011 00:56:45 +0200
>>>       
>>>> This is one of the reasons why I still think that
>>>> xt_SYSREQ would be the better solution, you get all
>>>> kinds of filtering features for free.
>>>>
>>>> You could even use crazy things like '-m time' to restrict
>>>> sysreq availability to working hours and whatnot.
>>>>
>>>>         
>>> Agreed.
>>>       
>> Using the netfilter xt-SYSRQ code seems to store the entered code and
>> execute it later after the system has returned to a normal state....
>> which is much too late to be useful.
>>     
> The target handler of the kernel part invokes handle_sysrq(),
> I don't see any delaying/queueing?
>   

Yeah ... It just occurred to me on the way into the office that I made a
mistake.

... What if the "slow down" I'm seeing is due to the network layer?  ...
but why would ping work and the xt_SYSRQ not work? 

Either way ... I have a feeling that I'm on to something,

P.

