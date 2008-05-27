From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: problem from netdev
Date: Tue, 27 May 2008 20:51:55 +0200
Message-ID: <483C584B.7060503@gmail.com>
References: <483BB88F.7080407@math.univ-toulouse.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.Bonnafous@math.univ-toulouse.fr
To: david.jesson@math.univ-toulouse.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:52854 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611AbYE0Sxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 14:53:36 -0400
Received: by ug-out-1314.google.com with SMTP id h2so63527ugf.16
        for <netdev@vger.kernel.org>; Tue, 27 May 2008 11:53:33 -0700 (PDT)
In-Reply-To: <483BB88F.7080407@math.univ-toulouse.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesson david wrote, On 05/27/2008 09:30 AM:

> hello,
> i am a technical informatic french so i've a very bad english, sorry.
> 
> i've a problem for the "netdev"  parameter.
> i've a dell 1950 with 4 nic, 2 onboard broadcom and 2 intel e1000.
> the server boot from pxelinux with this parameter
> i need to atribute eth0 to this card for a other script and i need to 
> eth0 has the card of irq 17 and io 0xdcc0
>> LABEL gentoo-linux-2.6.24.4-scsi
>>   MENU LABEL gentoo, linux 2.6.24.4, boot scsi
>>   MENU DEFAULT
>>   MENU PASSWD toto
>>   kernel kernel-genkernel-x86-2.6.24.4
>>   # options du noyau: root, init, ramdisk_size, initrd 
>> (Documentation/kernel-parameters.txt)
>>   # options du script linuxrc: real_root, no..., doscsi 
>> (/usr/share/genkernel/generic)
>>   append softlevel=default root=/dev/ram0 init=/linuxrc 
>> ramdisk_size=8192 real_root=/dev/sda6 nodhcp nogpm nohotplug nosound 
>> doscsi initrd=initramfs-genkernel-x86-2.6.24.4
> i tried to insert the netdev parameter :
> netdev=irq=17,io=0xdcc0,name=eth0 netdev=irq=16,io=0xdce0,name=eth1  but 
> after booting this parameter was not working: eth0 is not the card with 
> irq=16/io=dcc0 and it the same for this other nic. ( ifconfig and lspci -v)
> 
> 
> what is the problem ?? bad syntase or incompatible parameter ??
> 

Hi,

I hope somebody will correct me if I'm wrong, but it looks like this
method is used only by older cards, and not e1000 etc.

Regards,
Jarek P.
