From: Danie Wessels <dawessels@telkomsa.net>
Subject: Re: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T together
Date: Fri, 22 Jul 2011 16:52:29 +0200
Message-ID: <4E298EAD.7000200@telkomsa.net>
References: <4E26B198.4020606@telkomsa.net> <20110720122206.73898673@nehalam.ftrdhcpuser.net> <4E2752A2.3030208@telkomsa.net> <20110721102259.GA10481@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrba-ip-smtp-1-2.saix.net ([196.25.240.239]:42889 "EHLO
	rrba-ip-smtp-1-2.saix.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab1GVOve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 10:51:34 -0400
In-Reply-To: <20110721102259.GA10481@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 12:22 PM, Francois Romieu wrote:
> Danie Wessels<dawessels@telkomsa.net>  :
> [...]
>> gr8. I can give that a try
and ...
> Search for rtl8169_pci_tbl and remove the 0x8168 line : the kernel r8169
> driver will stop being used on the 8168s.
I see the r8168 driver was based on the r8169 of kernel 2.6.18 ?
{GPL of Copyrig.. with paten.. ??} see r8168-8.024.00.tar

ht tp://152 
.104.125.41/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=4&Level=5&Conn=4&DownTypeID=3&GetDown=false&Downloads=true
>>
>> .>It ought to be supported by the kernel r8169 driver.
>>
>> See bugs listed on Ubuntu:
>> https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/141343
>
> Executive summary :
> a. started in 2007
> b. includes "kernel r8169 driver does not work, tried Realtek's r8168,
>     happy now"
> c. includes b. +  "...wait a few days, Oops"
> d. covers different devices (8168b, 8168c, plain 8169).
> e. people still using old kernel (see post 2.6.26
>     77332894c21165404496c56763d7df6c15c4bb09 in #38 then mention of 2.6.22,
>     2.6.24)
> f. usual "this is the same bug" (#141343 is the same bug as #141343
??
> e. one (1) dmesg attached to the whole thread (74 messages). Tons of lspci,
>     not a single XID.
I think is is good summary!
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/221499
>
> Trend (?) : recent kernels help. XID and up-to-date reports would be
> welcome if they can be streamlined to a standard (for me :o) ) kernel.
> See below.
>
>> https://bugs.launchpad.net/linux/+bug/347711
>
> I wish I could filter out comments by author. Flat PR get really, really
> messy with time.
yes, I can understand
:
>> .>  Which problem(s) do you have with it ?
>> No communication to outside devices. I can not ping my router
>> through it but can ping its IP.
>
> So it is receiving packets either in promiscuous mode or (and)
> as long as its peer knows its MAC address ?
No. sorry, I think. What I meant is that I cannot ping any other IPs 
other than the that of the card itself (on this onboard card) with the 
r8169 driver.
Further: When I then rebooted to Win 7 the card also does not work until 
I disable the card and then re-enable the onboard card.
Then when I rebooted to the previous Ubuntu (i.e. 10.10) the card might 
work (if it was hot reboot..?)
>
> No Tx at all (it may help if you can capture traffic on the remote
> end) or just a few packets before it stops (and spits a NETDEV
> WATCHDOG message) ?
I will look into this.
>
:
 > - What (specific)
>    One of Ubuntu's report suggests that you are experiencing a regression.
>     If so it would be nice to bissect it.
Now even after a reboot (and disable/enable) from Win 7, Ubuntu 11.04 
does not have the card enabled any more.
> In the short run I can not do more as I must push something out for a mac
> address change problem with the 8168evl.
OK

-- 
Danie Wessels

