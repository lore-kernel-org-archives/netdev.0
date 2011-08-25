From: "J.Hwan Kim" <frog1120@gmail.com>
Subject: Re: how to distribute irqs of ixgbevf
Date: Thu, 25 Aug 2011 19:19:13 +0900
Message-ID: <4E5621A1.5050607@gmail.com>
References: <4E5602D6.90807@gmail.com> <1314260481.2387.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49806 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360Ab1HYKTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 06:19:17 -0400
Received: by gxk21 with SMTP id 21so1614114gxk.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 03:19:16 -0700 (PDT)
In-Reply-To: <1314260481.2387.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011=EB=85=84 08=EC=9B=94 25=EC=9D=BC 17:21, Eric Dumazet wrote:
> Le jeudi 25 ao=C3=BBt 2011 =C3=A0 17:07 +0900, J.Hwan Kim a =C3=A9cri=
t :
>> Hi, everyone
>>
>> The interrupts of my ixgbevf driver occurs only Core 0
>> although the user space "irqbalance" serivce is working.
>>
>> How can I distribute the interrupt of RX in ixgbevf to all cores?
>>
>> cat /proc/interrupts | grep "isv"
>>     97:          8          0          0          0          0
>> 0          0          0   PCI-MSI-edge      isv0-rx-0
>>     99:          7          0          0          0          0
>> 0          0          0   PCI-MSI-edge      isv0:lsc
>>    103:       2059      0          0          0          0
>> 0          0          0   PCI-MSI-edge      isv2-rx-0
>>    104:         14        0          0          0          0
>> 0          0          0   PCI-MSI-edge      isv2-tx-0
>>    105:          1         0          0          0          0
>> 0          0          0   PCI-MSI-edge      isv2:mbx
>>
>> "isv" is netdevice name of my ixgbevf.
>>
>>
> Given load is very small, irqbalance chose to send interrupts on a
> single cpu.

This is CPU load measured by "top" and my cores are 8.


   PID USER      PR  NI  VIRT  RES  SHR    S     %CPU      %MEM    =20
TIME+      COMMAND
     3 root         20   0     0     0    0        R       99          =
=20
0.0     70:05.48    ksoftirqd/0
