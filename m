From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 13:46:29 +0100
Message-ID: <564DC4A5.70104@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag>
 <564D9CE6.2090104@profihost.ag>
 <1447933294.1974772.444210441.67F1AC5E@webmail.messagingengine.com>
 <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:22895 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbKSMqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 07:46:31 -0500
In-Reply-To: <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 19.11.2015 um 13:41 schrieb Hannes Frederic Sowa:
> On Thu, Nov 19, 2015, at 12:43, Stefan Priebe - Profihost AG wrote:
>>
>> Am 19.11.2015 um 12:41 schrieb Hannes Frederic Sowa:
>>> On Thu, Nov 19, 2015, at 10:56, Stefan Priebe - Profihost AG wrote:
>>>> OK it had a livelock again. It just took more time.
>>>>
>>>> So here is the data:
>>>
>>> Thanks, I couldn't reproduce it so far with simple threaded resolver
>>> loop on your kernel. :/
>>>
>>> Your data is useless if you don't also provide the file descriptor which
>>> you are blocking on right now. ;)
>>>
>>> Thanks,
>>> Hannes
>>
>> ah sorry. So we need the gdb backtrace with the rcvmsg and then the fd
>> list + netlink list?
> 
> Yes, albeit the probability we find something new is minimal. We already
> know it blocks deep down in netlink code. I tried to reproduce it in
> multithreaded environment with no results so far. Can you even try a
> newer kernel?

I can try Kernel 4.4-rc1 next week. Or something else?

Stefan

> 
> Bye,
> Hannes
> 
