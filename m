From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x1f2/0x200()
Date: Tue, 20 Mar 2012 14:31:19 -0700
Message-ID: <4F68F727.9030405@gmail.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com> <4F2F0065.9040909@lwfinger.net> <20120205222141.GA26223@electric-eye.fr.zoreil.com> <20120205145913.194746473361e324bda1eb4a@gmail.com> <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com> <20120320093709.GA5058@electric-eye.fr.zoreil.com> <4F689131.2030607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:57872 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab2CTVb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 17:31:26 -0400
Received: by dajr28 with SMTP id r28so545875daj.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 14:31:26 -0700 (PDT)
In-Reply-To: <4F689131.2030607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2012 07:16 AM, Justin P. Mattock wrote:
> On 03/20/2012 02:37 AM, Francois Romieu wrote:
>> (Larry removed)
>>
>> Justin Mattock<justinmattock@gmail.com> :
>> [...]
>>> seems I see this with the latest linux-next:
>>
>> Thanks for testing.
>>
>> [...]
>>> [21740.318685] r8169 0000:06:00.0: eth0: link up
>>> [21752.292679] r8169 0000:06:00.0: eth0: link up
>>> [21764.268569] r8169 0000:06:00.0: eth0: link up
>>> [21776.254393] r8169 0000:06:00.0: eth0: link up
>>> [21788.235797] r8169 0000:06:00.0: eth0: link up
>>> [21800.196524] r8169 0000:06:00.0: eth0: link up
>>> [21812.172497] r8169 0000:06:00.0: eth0: link up
>>
>> This is completely broken. I could understand a few up/down link changes
>> until things settles but the driver should not claim periodically that
>> the link is up when there is no cable, at least not with a supported
>> chipset.
>>
>> Can you apply the debug helper below and report a complete dmesg from
>> boot with the same test (please remove l-k, netdev is good enough) ?
>
> I removed linux-kernel from the Cc's and applied your patch.. system
> built fine, and suspend wakes up fine without the ethernet trying to
> connect like it was doing. will run this patch for a few Thanks for this!
>
> dmesg is here: http://fpaste.org/jHSX/
> (I have another patch added in, but it should not affect anything).
>
>

well i dont know what happened.. I suspend throughout the day without 
any issues, but then on one wakeup everything went to crap ethernet 
started to try and connect without any wires in.. only thing I can think 
of is I was dongling with my phone(but the phone was disconnected before 
suspend),which uses a different module..

dmesg here:
http://fpaste.org/mcNC/

Justin P. Mattock
