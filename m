From: Tina Yang <tina.yang@oracle.com>
Subject: Re: [Bugme-new] [Bug 9124] New: Netconsole race crashed the system
Date: Fri, 05 Oct 2007 18:32:29 -0700
Message-ID: <4706E5AD.6070504@oracle.com>
References: <470592E8.7080809@oracle.com>	<20071004202414.0f1eddb7@freepuppy.rosehill>	<4705B602.6090306@oracle.com> <20071004.222219.02300073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:63725 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbXJFBgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 21:36:24 -0400
In-Reply-To: <20071004.222219.02300073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tina Yang <tina.yang@oracle.com>
> Date: Thu, 04 Oct 2007 20:56:50 -0700
>
>   
>>     Yes, it's RHEL5 2.6.18-8.  Attached is the 2.6.9-42 version that 
>> doesn't have 802.11 and
>>     crashed at the same spot - netdevice.h:888.  Also crashed are 
>> 2.6.23-rc2 and rc4.
>>     
>
> 2.6.9-42 is, again, a vendor modified kernel.
>
> Please show the crash information against vanilla upstream kernels if
> you want us to take a serious look at this, thanks a lot.
>   
Ok, I ran it on 2.6.23-rc8, hang.
Console said  panicked at tg3_poll+0x747 - netdevice.h:1008, same place ?
I am not sure if I can get a core dump at this point...

 =======================
Code:  0f b7 42 10 3b 43 60 0f 85 a3 00 00 00 85 c9 0f 94 c0 0f b6 f0 85 
f6 0f 84
 95 00 00 00 9c 5b fa 8b 6c 24 08 8b 45 2c a8 20 75 04 <0f> 0b eb fe 8b 
44 24 08
 05 80 01 00 00 e8 09 d3 b3 c7 8b 44 24
EIP: [<f89a975d>] tg3_poll+0x747/0x7ee (tg3) SS:ESP 0068:c0753f80
Kernel panic - not syncing: Fatal exception in interrupt

