From: "Kevin D. Kissell" <kevink@mips.com>
Subject: Re: Patch to add M3Pnet Driver
Date: Tue, 17 Jun 2008 15:40:43 +0200
Message-ID: <4857BEDB.8080603@mips.com>
References: <4835F799.6070302@mips.com> <20080523023623.GA17651@linux-mips.org> <4836F40C.804@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mips.com ([63.167.95.198]:59419 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434AbYFQNkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 09:40:09 -0400
In-Reply-To: <4836F40C.804@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Ralf and I never heard back from you on this one.  Have you had
a chance to think about it yet?

          Regards,

          Kevin K.

Kevin D. Kissell wrote:
> Guysm
>
> Yet another network driver is probably not what the world needs most,
> but I had to write one for MIPS Linux this month that was a little
> different from any of the others.  It's a driver that impersonates
> an ethernet interface whilst actually passing packets in memory between
> different processors running different OS images in a shared memory
> environment, something that actually happens in embedded systems.
> I call it M3P (pronounced "mep"), for MIPS Memory Message Passing,
> but if I didn't think it could be adapted to non-MIPS based and indeed
> heterogeneous systems, I wouldn't trouble you with it.  I note that
> the "mipsnet" driver, which is limited in its function to running
> on a MIPS simulator, made it in, so I figured I'd at least ask if
> it's something that could be absorbed into the network driver mass,
> the better for other folks to improve on it - there are a lot of
> enhancements I'd like to make, some of which are described in the
> comments, but it's not clear that I'll have time to make them any
> time soon.  A familiar refrain, I suppose.  Anyway, the patch is
> attached.  See also Ralf's ack below.
>
>             Regards,
>
>             Kevin K.
>
> Ralf Baechle wrote:
>> On Fri, May 23, 2008 at 12:45:45AM +0200, Kevin D. Kissell wrote:
>>> From: "Kevin D. Kissell" <kevink@mips.com>
>>> Date: Fri, 23 May 2008 00:45:45 +0200
>>> To: Linux MIPS Org <linux-mips@linux-mips.org>
>>> Subject: Patch to add M3Pnet Driver
>>> Content-Type: multipart/mixed;
>>>     boundary="------------050707080700070300010401"
>>>
>>> As per previous messages, here's 2 of 2
>>
>> This is largely a network driver patch with minor arch bits thrown in so
>> this one will have to go via jeff@garzik.org and netdev@vger.kernel.org.
>> The MIPS bits are looking good though so feel free to add my
>>
>> Acked-by: Ralf Baechle <ralf@linux-mips.org>
>>
>> line for them.
>>
>>   Ralf
>
