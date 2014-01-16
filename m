From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Subject: Re: throughput problems with realtek
Date: Thu, 16 Jan 2014 20:47:13 +0200
Message-ID: <CACE9dm-ObDjif3+Ojhb-veQnhLCPurieJkxBw2pschUYeHvsgA@mail.gmail.com>
References: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
	<52D6B5F4.1060201@hp.com>
	<CACE9dm92Wu=XwCChXJjjsz=FEWAgJW-1iLRw5-d4c5ZTCYVe3w@mail.gmail.com>
	<20140115235123.GA6773@electric-eye.fr.zoreil.com>
	<CACE9dm9s6k+PgkU4hFJvdKr8_fC7SBPiDnQuD4C4pJrUJT1Uiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hp.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, l.moiseichuk@samsung.com,
	kernel-team <kernel-team@lists.ubuntu.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:59932 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaAPSrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 13:47:14 -0500
Received: by mail-wg0-f49.google.com with SMTP id a1so3622134wgh.16
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 10:47:13 -0800 (PST)
In-Reply-To: <CACE9dm9s6k+PgkU4hFJvdKr8_fC7SBPiDnQuD4C4pJrUJT1Uiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 9:45 AM, Dmitry Kasatkin
<dmitry.kasatkin@gmail.com> wrote:
> On Thu, Jan 16, 2014 at 1:51 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> Dmitry Kasatkin <dmitry.kasatkin@gmail.com> :
>> [...]
>>> I do not see any link speed changes... it stays the same...
>>> The same problem is visible on absolutely different computers.
>>
>> No netdev watchdog message either ?
>>
>> A serving 8168c does not seem to fluctuate (3.12.5, Intel 82578 client).
>> My hardware is a bit old though. Please send XID message from the r8169
>> driver. It should be seen in dmesg.
>>
>> Thanks.
>>
>> --
>> Ueimor
>
> Hi,
>
> No watchdog messages. I also do not see any changes in the led on the
> switch which indicates changes in the link speed.
>
> Also as you say.. speed drop first to 140MBs so it is still higher than 100MBs
>
> This what I have in dmesg...
>
> [    2.005555] r8169 0000:03:00.0: irq 45 for MSI/MSI-X
> [    2.005690] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at
> 0xffffc90000040000, 18:67:b0:2c:0f:ef, XID 0c900800 IRQ 45
> [    2.005691] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200
> bytes, tx checksumming: ko]
>
> Is it that XID or something else..
>
> I have a problem on Gygabyte Celleron 1007U integrated board and also
> on Samsung Series 7 laptop.
> My colleague has the same on his Series 7 laptop.
>
> One thing.. I had similar problem with Intel network card. It was
> fixed using module parameter...
>
> modprobe e1000e InterruptThrottleRate=0
>
> Are there any network speed or irq throttling in kernel/driver?
>
> --
> Thanks,
> Dmitry

Hello,

CC: Ubuntu kernel team.

In fact after installing kernel from PPA everything seems to be fine.

http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.12.8-trusty/

So the problem is somewhere in Ubuntu 3.11-0.15 kernel...

May be Ubuntu kernel team might test and release "better" default kernel...

-- 
Thanks,
Dmitry
