From: Vadym Abramchuk <abramm@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Tue, 24 May 2011 19:09:06 +0300
Message-ID: <BANLkTi=tKi9hOFy4Ctnv=ZgOcU-0dP38AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39726 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563Ab1EXQJ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 12:09:27 -0400
Received: by qwk3 with SMTP id 3so3439195qwk.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 09:09:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2011 15:17:49 +0200, Eric Dumazet wrote:
> Le mardi 24 mai 2011 =E0 01:35 +0300, Denys Fedoryshchenko a =E9crit =
:
>> On Mon, 23 May 2011 17:05:46 +0200, Eric Dumazet wrote:
>> > Le lundi 23 mai 2011 =E0 17:27 +0300, Denys Fedoryshchenko a =E9cr=
it :
>> >
>> >> > Thanks !
>> >> =A0By objdump or he must recompile kernel with DEBUG_INFO and use
>> gdb?
>> >>
>> >>
>> >>
>> >
>> >
>> > Just objdump of sch_sfq.o (or sch_sfq.ko) file, (to keep existing
>> > offsets), thanks
>> =A0Sorry for delay, i had to contact person who run that kernel :)
>>
>> =A0www.nuclearcat.com/files/disasm.txt
>> =A0www.nuclearcat.com/files/sch_sfq.ko
>>
>>
>
> Thanks !
>
> BTW, does this person have another bug trace to feed us ?
>
> I tried to reproduce it here but failed.
>
> full dmesg might help too

Greetings.

This error is at my server and I'm 'that' person.
Denys' help is useful, but I decided to join the netlist myself to
stop annoying him. :)
I haven't been using mailing lists for a while, so I hope this mail
will get to the right thread.

Right now, the machine is closed at the server room so I'll be able to
get some more
debug info only tomorrow.

What more info can I supply besides dmesg? Maybe I should rebuild the
kernel with some
debug options enabled?

WBR, Vadym
