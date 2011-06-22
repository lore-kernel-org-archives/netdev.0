From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Wed, 22 Jun 2011 06:26:23 -0400
Message-ID: <4E01C34F.6050009@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>	<4E0115B3.2030802@redhat.com>	<20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, fbl@redhat.com, netdev@vger.kernel.org,
	agospoda@redhat.com, nhorman@redhat.com, lwoodman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab1FVK0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 06:26:31 -0400
In-Reply-To: <20110621.155816.1840729860084652508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/21/2011 06:58 PM, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Wed, 22 Jun 2011 00:56:45 +0200
>
>   
>> Flavio Leitner <fbl@redhat.com> wrote:
>>     
>>> What about a whitelist of source MAC or IP addresses to accept the sysrq?
>>>       
>> This is one of the reasons why I still think that
>> xt_SYSREQ would be the better solution, you get all
>> kinds of filtering features for free.
>>
>> You could even use crazy things like '-m time' to restrict
>> sysreq availability to working hours and whatnot.
>>     
> Agreed.
>   

It is not the same thing.  At least AFAICT ... I have a system in which
we're experiencing random pauses.  That is, unlike a hang or a
softlockup the system just (for lack of a better word) slows down.

Typing through the keyboard is lagged as is output on the console. 
Running the date command in the background shows that the date is not
updated for 30-40 seconds.  I got lucky this morning, logged in an
noticed that the system I've been watching was in this state :)

Using the ping, I can get a sysrq-c/t/m/whatever into the system
immediately.

Using the netfilter xt-SYSRQ code seems to store the entered code and
execute it later after the system has returned to a normal state....
which is much too late to be useful.

I want/need an *immediate* way to sysrq the machine.

P.
