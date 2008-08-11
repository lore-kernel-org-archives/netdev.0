From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Mon, 11 Aug 2008 09:53:54 +0200
Message-ID: <a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	 <48975BD3.6040709@shaw.ca>
	 <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	 <20080807185802.GA16327@electric-eye.fr.zoreil.com>
	 <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:39968 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbYHKHxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 03:53:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2136918rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 00:53:54 -0700 (PDT)
In-Reply-To: <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Sun, Aug 10, 2008 at 9:00 PM, Dushan Tcholich <dusanc@gmail.com> wrote:
> Hi
> Sorry for answering this late, but I was short on time and couldn't
> get reiser4 to work with 2.6.27-rc2
>
> On Thu, Aug 7, 2008 at 8:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> Dushan Tcholich <dusanc@gmail.com> :
>> [...]
>>> I googled a little and found out that oprofile is a little above my head.
>>> So as I thought that some driver or HW might be responsible for this I
>>> tried to disable various onboard HW and found out that if I disable
>>> onboard ethernet problem dissapears, so now I've added netdev and
>>> maintainer of R8169 driver to cc.
>>
>> Can you try 2.6.27-rc2 and send the content of /proc/interrupts, dmesg,
>> ifconfig as well as a capture of the strange output from top ?
>>

I tried some more kernels and I had the same problem with 2.6.23.17
and 2.6.27-rc1-mm1, but I couldn't reproduce it with kernel from
sysresccd 1.0.1 http://www.sysresccd.org/ which is a patched version
of 2.6.24 i think .7 when I booted it to change fs.
Could it be that something in userspace is creating this?

> I've copied my root to ext3 partition and with vanilla 2.6.27-rc2 I got:
> -With my .config problem is still here
> -With only rtl8169 removed from config there is no problem
>
>> It seems rather benign though.
>>
> Well I wouldn't agree from power managment standpoint :). This nic is
> in a lot of laptops.
> 8% of 2.13GHz Core2Duo CPU is a lot :)
>
> Btw. should LKML be removed from cc?
> If you need any more help please ask.
> I hope I'm not harrasing you too much :)
>> --
>> Ueimor
>>
> Have a nice day
> Dushan
>
...
