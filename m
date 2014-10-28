From: "Stefan Bottelier | Ocius.nl" <stefan@ocius.nl>
Subject: Re: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit
 Ethernet Driver
Date: Tue, 28 Oct 2014 15:07:30 +0100
Message-ID: <544FA322.9000502@ocius.nl>
References: <544A110C.4030402@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B85038@avmb3.qlogic.org> <544E057C.2070204@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B860DB@avmb3.qlogic.org>,<544E6597.2040201@ocius.nl>,<B5657A6538887040AD3A81F1008BEC63B86A3E@avmb3.qlogic.org> <B5657A6538887040AD3A81F1008BEC63B86AD9@avmb3.qlogic.org> <544F5454.3000103@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B86E04@avmb3.qlogic.org> <544F68D2.9090902@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B86E89@avmb3.qlogic.org> <544F6CA9.3080705@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B86EA5@avmb3.qlogic.org> <544F7B33.5020204@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B86FA2@avmb3.qlogic.org> <544F8C29.6040305@ocius.nl> <B5657A6538887040AD3A81F1008BEC63B87028@avmb3.qlogic.org> <544F8E96.2020904@ocius.nl> <B5657A6538887
 040AD3A81F1008BEC63B87612@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Axlion.ocius.nl ([178.18.143.21]:29599 "EHLO Axlion.ocius.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbaJ1OHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2014 10:07:34 -0400
Received: from hannibal.xs4all.nl ([83.160.92.76] helo=MacBook-Pro-Retina-van-Stefan.local)
	by Axlion.ocius.nl with esmtpsa (TLSv1:DHE-RSA-AES128-SHA:128)
	(Exim 4.83)
	(envelope-from <stefan@ocius.nl>)
	id 1Xj7Ej-0008Nc-AW
	for netdev@vger.kernel.org; Tue, 28 Oct 2014 14:55:01 +0100
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B87612@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have fix some problems, but now i get the interface firmware not 
working, are the some tips of tricks for this ? Its for a Blade Servers, 
and this working the best with the kernel 3.2.0 branch. So i hope 
somebody can help me whit this.

[   76.803495] bnx2x: [bnx2x_init_firmware:10573(eth0)]Can't load 
firmware file bnx2x/bnx2x-e2-7.0.29.0.fw
[   76.803508] bnx2x: [bnx2x_func_hw_init:5382(eth0)]Error loading firmware
[   76.803523] bnx2x: [bnx2x_nic_load:1847(eth0)]HW init failed, aborting

> You can try netdev again, or you should try with the distro bugzillas
> [I'm not sure if request_firmware() is contained entirely in kernel or is dependent on some tools in the filesystem provided by the distro]
>
>> -----Original Message-----
>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>> Sent: Tuesday, October 28, 2014 2:40 PM
>> To: Yuval Mintz
>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx 10/20-
>> Gigabit Ethernet Driver
>>
>> Are the some places where i get drop this question ? I hope so that i get it
>> working on this Dell Server.
>>
>>> Sounds like a small technicality, but sadly I cannot help you from afar.
>>>
>>>> -----Original Message-----
>>>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>>>> Sent: Tuesday, October 28, 2014 2:29 PM
>>>> To: Yuval Mintz
>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx
>>>> 10/20- Gigabit Ethernet Driver
>>>>
>>>> Any ideas?
>>>>
>>>> why this message will be coming up.
>>>>
>>>> [   76.074999] bnx2x: [bnx2x_init_firmware:10573(eth0)]Can't load
>>>> firmware file bnx2x/bnx2x-e2-7.0.29.0.fw
>>>> [   76.075011] bnx2x: [bnx2x_func_hw_init:5382(eth0)]Error loading firmware
>>>> [   76.075032] bnx2x: [bnx2x_nic_load:1847(eth0)]HW init failed, aborting
>>>>
>>>> I have change the firmware in
>>>>
>>>> bnx2x_main.c and i have set the firmware images in
>>>> /lib/firmware/bnx2x
>>>>
>>>>
>>>>> You can get it from by cloning the linux-firmware git repository at
>>>>> - git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.
>>>>> git
>>>>>
>>>>>> -----Original Message-----
>>>>>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>>>>>> Sent: Tuesday, October 28, 2014 1:17 PM
>>>>>> To: Yuval Mintz
>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II 5771x/578xx
>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>
>>>>>> Hello Yuval,
>>>>>>
>>>>>> Now i get no erro's only the follwing imforation
>>>>>> [   18.340531] bnx2x 0000:01:00.0: Bad FW version:6.2.9.0. Should be
>>>>>> 7.0.29.0
>>>>>> [   18.340542] bnx2x: [bnx2x_init_firmware:10579(eth0)]Corrupt firmware
>>>>>> file bnx2x/bnx2x-e2-6.2.9.0.fw
>>>>>> [   18.340550] bnx2x: [bnx2x_func_hw_init:5382(eth0)]Error loading
>> firmware
>>>>>> [   18.340562] bnx2x: [bnx2x_nic_load:1847(eth0)]HW init failed, aborting
>>>>>>
>>>>>> If are a location where i can download the 7.0.29.0 firmware, i
>>>>>> change to the kernel firmware but this don't work. So i a searching
>>>>>> for the
>>>>>> 7.0.29.0 firmware.
>>>>>>
>>>>>>> Hi,
>>>>>>>
>>>>>>> The change might affect you - you're using a new board.
>>>>>>>
>>>>>>> Cheers,
>>>>>>> Yuval
>>>>>>>
>>>>>>>> -----Original Message-----
>>>>>>>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>>>>>>>> Sent: Tuesday, October 28, 2014 12:15 PM
>>>>>>>> To: Yuval Mintz
>>>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>> 5771x/578xx
>>>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>>>
>>>>>>>> Hello Yuval,
>>>>>>>>
>>>>>>>> Whithout code change i see.
>>>>>>>>
>>>>>>>> bash-4.3# ethtool -i eth0
>>>>>>>> driver: bnx2x
>>>>>>>> version: 1.70.30-0
>>>>>>>> firmware-version: bc 7.10.11
>>>>>>>> bus-info: 0000:01:00.0
>>>>>>>>
>>>>>>>>> Btw,
>>>>>>>>>
>>>>>>>>> You can supply `ethtool -i' output on one of the interfaces to
>>>>>>>>> see whether the
>>>>>>>> warning would actually apply.
>>>>>>>>> Thanks,
>>>>>>>>> Yuval
>>>>>>>>>
>>>>>>>>>> -----Original Message-----
>>>>>>>>>> From: Yuval Mintz
>>>>>>>>>> Sent: Tuesday, October 28, 2014 12:07 PM
>>>>>>>>>> To: 'Stefan Bottelier | Ocius.nl'
>>>>>>>>>> Subject: RE: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>> 5771x/578xx
>>>>>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>>>>>
>>>>>>>>>> Well,
>>>>>>>>>>
>>>>>>>>>> There is actually a WARN_ON in line 8886, and that warning was
>>>>>>>>>> later removed for newer boards.
>>>>>>>>>>
>>>>>>>>>> Please try removing it and changing to the code in
>>>>>>>>>> bnx2x_get_igu_cam_info() from upstream kernel, and see what's
>> next.
>>>>>>>>>> Cheers,
>>>>>>>>>> Yuval
>>>>>>>>>>
>>>>>>>>>>> -----Original Message-----
>>>>>>>>>>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>>>>>>>>>>> Sent: Tuesday, October 28, 2014 11:59 AM
>>>>>>>>>>> To: Yuval Mintz
>>>>>>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>>> 5771x/578xx
>>>>>>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>>>>>>
>>>>>>>>>>> Hello Yuval,
>>>>>>>>>>>
>>>>>>>>>>> I have change this in the
>>>>>>>>>>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
>>>>>>>>>>>
>>>>>>>>>>> With new code from the 3.10 kernel
>>>>>>>>>>>
>>>>>>>>>>> static void bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16
>>>>>>>>>>> mac_hi)
>>>> {
>>>>>>>>>>>               __be16 mac_hi_be = cpu_to_be16(mac_hi);
>>>>>>>>>>>               __be32 mac_lo_be = cpu_to_be32(mac_lo);
>>>>>>>>>>>               memcpy(mac_buf, &mac_hi_be, sizeof(mac_hi_be));
>>>>>>>>>>>               memcpy(mac_buf + sizeof(mac_hi_be), &mac_lo_be,
>>>>>>>>>>> sizeof(mac_lo_be)); }
>>>>>>>>>>>
>>>>>>>>>>> Now i get the following message back
>>>>>>>>>>>
>>>>>>>>>>> [    5.748765] WARNING: at
>>>>>>>>>>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:8886
>>>>>>>>>>> bnx2x_init_one+0xd04/0x2786()
>>>>>>>>>>> [    5.748767] Hardware name: PowerEdge M620
>>>>>>>>>>> [    5.748769] Modules linked in:
>>>>>>>>>>> [    5.748773] Pid: 1, comm: swapper/0 Tainted: G        W 3.2.63 #1
>>>>>>>>>>>
>>>>>>>>>>> Are this correct my change in this code ?
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>> Hi Stefan,
>>>>>>>>>>>>
>>>>>>>>>>>> Are you using a Big-Endian machine?
>>>>>>>>>>>>
>>>>>>>>>>>> Regardless, I don't really have anything 'good' to tell you -
>>>>>>>>>>>> the code you've given me is the same as the one I've looked
>>>>>>>>>>>> at, and line
>>>>>>>>>>>> 9410 doesn't
>>>>>>>>>>> really include anything that should produce a warn [at most, a
>>>>>>>>>>> NULL pointer dereference].
>>>>>>>>>>>> Regardless, if you can - you can try to replace the
>>>>>>>>>>>> implementation of
>>>>>>>>>>>> bnx2x_set_mac_buf() in your kernel in bnx2x_main.c with the
>>>>>>>>>>>> one from more
>>>>>>>>>>> modern kernels; [It doesn't pass address of parameters to the
>>>>>>>>>>> function] and see if it solves your issue.
>>>>>>>>>>>> Cheers,
>>>>>>>>>>>> Yuval
>>>>>>>>>>>>
>>>>>>>>>>>>> -----Original Message-----
>>>>>>>>>>>>> From: Stefan Bottelier | Ocius.nl [mailto:stefan@ocius.nl]
>>>>>>>>>>>>> Sent: Tuesday, October 28, 2014 10:31 AM
>>>>>>>>>>>>> To: Yuval Mintz
>>>>>>>>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>>>>> 5771x/578xx
>>>>>>>>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>>>>>>>>
>>>>>>>>>>>>> Hello Yuval,
>>>>>>>>>>>>>
>>>>>>>>>>>>> Correct i use 32bits machine
>>>>>>>>>>>>>
>>>>>>>>>>>>> 3.2.63 #1 SMP Mon Oct 27 11:22:59 CET 2014 i686 i686 i386
>>>>>>>>>>>>> GNU/Linux
>>>>>>>>>>>>>
>>>>>>>>>>>>> I have added new files. objdump i have run this command in
>>>>>>>>>>>>> the bnx2x dir from the kernel source, i hope thats is oke ?
>>>>>>>>>>>>>
>>>>>>>>>>>>> Thanks,
>>>>>>>>>>>>> Stefan
>>>>>>>>>>>>>> Hi Stefan,
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> 2 things:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> 1. For some reason the source files I'm looking at don't
>>>>>>>>>>>>>> look the same as
>>>>>>>>>>>>> yours.
>>>>>>>>>>>>>> If you can, please tarball me the bnx2x directory from the
>>>>>>>>>>>>>> kernel sources
>>>>>>>>>>>>> you've compile and send it to me.
>>>>>>>>>>>>>> 2. objdump doesn't contain the source code; Are you sure
>>>>>>>>>>>>>> you've used
>>>>>>>>>>>>> `objdump -S' as opposed to simple `objdump' when generating it?
>>>>>>>>>>>>>> 3. Just to be certain, you're using a 32-bit machine, right?
>>>>>>>>>>>>>> [Don't know if it's related, but it's rare enough that I
>>>>>>>>>>>>>> should consider it when I look at the issue]
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Thanks,
>>>>>>>>>>>>>> Yuval
>>>>>>>>>>>>>> ________________________________________
>>>>>>>>>>>>>> From: Yuval Mintz
>>>>>>>>>>>>>> Sent: Monday, October 27, 2014 8:38 AM
>>>>>>>>>>>>>> To: Stefan Bottelier | Ocius.nl
>>>>>>>>>>>>>> Subject: RE: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>>>>>> 5771x/578xx 10/20-Gigabit Ethernet Driver
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Hi Stefan - I have, but I still haven't been able to look into it.
>>>>>>>>>>>>>> ________________________________________
>>>>>>>>>>>>>> From: Stefan Bottelier | Ocius.nl [stefan@ocius.nl]
>>>>>>>>>>>>>> Sent: Monday, October 27, 2014 8:32 AM
>>>>>>>>>>>>>> To: Yuval Mintz
>>>>>>>>>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>>>>>> 5771x/578xx 10/20-Gigabit Ethernet Driver
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Hello Yuval,
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Do you have received my file's good ? I am not sure..
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Thanks,
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Hi Stefan,
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Just looked into 3.2.63 [Saber-toothed Squirrel] sources,
>>>>>>>>>>>>>>> and
>>>>>>>>>>>>>>> bnx2x_main:9410 doesn't look as if it contains any code
>>>>>>>>>>>>>>> that can throw a
>>>>>>>>>>>>> stack trace, Nor is it a [direct] part of bnx2x_init_one.
>>>>>>>>>>>>>>> Perhaps you can send the output of `objdump -S bnx2x.ko',
>>>>>>>>>>>>>>> so I could take a
>>>>>>>>>>>>> look at the place the stack trace points as the source of the issue?
>>>>>>>>>>>>>>> Cheers,
>>>>>>>>>>>>>>> Yuval
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> -----Original Message-----
>>>>>>>>>>>>>>>> From: Stefan Bottelier | Ocius.nl
>>>>>>>>>>>>>>>> [mailto:stefan@ocius.nl]
>>>>>>>>>>>>>>>> Sent: Monday, October 27, 2014 10:43 AM
>>>>>>>>>>>>>>>> To: Yuval Mintz
>>>>>>>>>>>>>>>> Cc: netdev
>>>>>>>>>>>>>>>> Subject: Re: Problem with 10Gbit Broadcom NetXtreme II
>>>>>>>>>>>>>>>> 5771x/578xx
>>>>>>>>>>>>>>>> 10/20- Gigabit Ethernet Driver
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Hello Yuval,
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Thanks for this messages.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> We use now the kernel 3.10.57 and then the interface
>>>>>>>>>>>>>>>> working, only we must back to the kernel we always use
>>>>>>>>>>>>>>>> 3.2.63 , its work better with use
>>>>>>>>>>>>> systems.
>>>>>>>>>>>>>>>> I have compiler the kernel by my self on a Suse system.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> I hope we can fix it, that this working with the kernel 3.2.63.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>> We are using Dell Blade Centers, but we get a error on
>>>>>>>>>>>>>>>>>> the 10Gbit Broadcom adapter bnx2x bnx2x 0000:01:00.0:
>>>>>>>>>>>>>>>>>> part number
>>>>>>>>>>>>>>>>>> 394D4342-31383735-30315430-473030
>>>>>>>>>>>>>>>>>> WARNING: at
>>>>>>>>>>>>>>>>>> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:9410
>>>>>>>>>>>>>>>>> Hi Stefan,
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> Which distro & linux kernel are you using?
>>>>>>>>>>>>>>>>> [Obviously not net-next]
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> Thanks,
>>>>>>>>>>>>>>>>> Yuval
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> ________________________________
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> This message and any attached documents contain
>>>>>>>>>>>>>>>>> information from the
>>>>>>>>>>>>>>>> sending company or its parent company(s), subsidiaries,
>>>>>>>>>>>>>>>> divisions or branch offices that may be confidential. If
>>>>>>>>>>>>>>>> you are not the intended recipient, you may not read,
>>>>>>>>>>>>>>>> copy, distribute, or use this information. If you have
>>>>>>>>>>>>>>>> received this transmission in error, please notify the
>>>>>>>>>>>>>>>> sender immediately by reply e-mail and then delete this
>>>>>>>>>>> message.
>>>>>>>>>>>>>>>> --
>>>>>>>>>>>>>>>> Met vriendelijke groet,
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Stefan Bottelier
>>>>>>>>>>>>>>>> Ocius Internet Services
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>>>>>>>>>>>> T: +31 (0)20 716 39 09
>>>>>>>>>>>>>>>> W: http://www.ocius.nl
>>>>>>>>>>>>>>> ________________________________
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> This message and any attached documents contain
>>>>>>>>>>>>>>> information from the
>>>>>>>>>>>>> sending company or its parent company(s), subsidiaries,
>>>>>>>>>>>>> divisions or branch offices that may be confidential. If you
>>>>>>>>>>>>> are not the intended recipient, you may not read, copy,
>>>>>>>>>>>>> distribute, or use this information. If you have received
>>>>>>>>>>>>> this transmission in error, please notify the sender
>>>>>>>>>>>>> immediately by reply e-mail and then delete this
>>>>>>>>>> message.
>>>>>>>>>>>>>> --
>>>>>>>>>>>>>> Met vriendelijke groet,
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> Stefan Bottelier
>>>>>>>>>>>>>> Ocius Internet Services
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>>>>>>>>>> T: +31 (0)20 716 39 09
>>>>>>>>>>>>>> W: http://www.ocius.nl
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> ________________________________
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> This message and any attached documents contain information
>>>>>>>>>>>>>> from the
>>>>>>>>>>>>> sending company or its parent company(s), subsidiaries,
>>>>>>>>>>>>> divisions or branch offices that may be confidential. If you
>>>>>>>>>>>>> are not the intended recipient, you may not read, copy,
>>>>>>>>>>>>> distribute, or use this information. If you have received
>>>>>>>>>>>>> this transmission in error, please notify the sender
>>>>>>>>>>>>> immediately by reply e-mail and then delete this
>>>>>>>>>> message.
>>>>>>>>>>>>> --
>>>>>>>>>>>>> Met vriendelijke groet,
>>>>>>>>>>>>>
>>>>>>>>>>>>> Stefan Bottelier
>>>>>>>>>>>>> Ocius Internet Services
>>>>>>>>>>>>>
>>>>>>>>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>>>>>>>>> T: +31 (0)20 716 39 09
>>>>>>>>>>>>> W: http://www.ocius.nl
>>>>>>>>>>>> ________________________________
>>>>>>>>>>>>
>>>>>>>>>>>> This message and any attached documents contain information
>>>>>>>>>>>> from the
>>>>>>>>>>> sending company or its parent company(s), subsidiaries,
>>>>>>>>>>> divisions or branch offices that may be confidential. If you
>>>>>>>>>>> are not the intended recipient, you may not read, copy,
>>>>>>>>>>> distribute, or use this information. If you have received this
>>>>>>>>>>> transmission in error, please notify the sender immediately by
>>>>>>>>>>> reply e-mail and then delete this
>>>>>> message.
>>>>>>>>>>> --
>>>>>>>>>>> Met vriendelijke groet,
>>>>>>>>>>>
>>>>>>>>>>> Stefan Bottelier
>>>>>>>>>>> Ocius Internet Services
>>>>>>>>>>>
>>>>>>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>>>>>>> T: +31 (0)20 716 39 09
>>>>>>>>>>> W: http://www.ocius.nl
>>>>>>>>> ________________________________
>>>>>>>>>
>>>>>>>>> This message and any attached documents contain information from
>>>>>>>>> the
>>>>>>>> sending company or its parent company(s), subsidiaries, divisions
>>>>>>>> or branch offices that may be confidential. If you are not the
>>>>>>>> intended recipient, you may not read, copy, distribute, or use
>>>>>>>> this information. If you have received this transmission in
>>>>>>>> error, please notify the sender immediately by reply e-mail and
>>>>>>>> then delete this
>>>> message.
>>>>>>>> --
>>>>>>>> Met vriendelijke groet,
>>>>>>>>
>>>>>>>> Stefan Bottelier
>>>>>>>> Ocius Internet Services
>>>>>>>>
>>>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>>>> T: +31 (0)20 716 39 09
>>>>>>>> W: http://www.ocius.nl
>>>>>>> ________________________________
>>>>>>>
>>>>>>> This message and any attached documents contain information from
>>>>>>> the
>>>>>> sending company or its parent company(s), subsidiaries, divisions
>>>>>> or branch offices that may be confidential. If you are not the
>>>>>> intended recipient, you may not read, copy, distribute, or use this
>>>>>> information. If you have received this transmission in error,
>>>>>> please notify the sender immediately by reply e-mail and then delete this
>> message.
>>>>>>
>>>>>> --
>>>>>> Met vriendelijke groet,
>>>>>>
>>>>>> Stefan Bottelier
>>>>>> Ocius Internet Services
>>>>>>
>>>>>> E: Stefan.Bottelier@ocius.nl
>>>>>> T: +31 (0)20 716 39 09
>>>>>> W: http://www.ocius.nl
>>>>> ________________________________
>>>>>
>>>>> This message and any attached documents contain information from the
>>>> sending company or its parent company(s), subsidiaries, divisions or
>>>> branch offices that may be confidential. If you are not the intended
>>>> recipient, you may not read, copy, distribute, or use this
>>>> information. If you have received this transmission in error, please
>>>> notify the sender immediately by reply e-mail and then delete this message.
>>>>
>>>>
>>>> --
>>>> Met vriendelijke groet,
>>>>
>>>> Stefan Bottelier
>>>> Ocius Internet Services
>>>>
>>>> E: Stefan.Bottelier@ocius.nl
>>>> T: +31 (0)20 716 39 09
>>>> W: http://www.ocius.nl
>>> ________________________________
>>>
>>> This message and any attached documents contain information from the
>> sending company or its parent company(s), subsidiaries, divisions or branch
>> offices that may be confidential. If you are not the intended recipient, you may
>> not read, copy, distribute, or use this information. If you have received this
>> transmission in error, please notify the sender immediately by reply e-mail and
>> then delete this message.
>>
>>
>> --
>> Met vriendelijke groet,
>>
>> Stefan Bottelier
>> Ocius Internet Services
>>
>> E: Stefan.Bottelier@ocius.nl
>> T: +31 (0)20 716 39 09
>> W: http://www.ocius.nl
>
> ________________________________
>
> This message and any attached documents contain information from the sending company or its parent company(s), subsidiaries, divisions or branch offices that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.


-- 
Met vriendelijke groet,

Stefan Bottelier
Ocius Internet Services

E: Stefan.Bottelier@ocius.nl
T: +31 (0)20 716 39 09
W: http://www.ocius.nl
