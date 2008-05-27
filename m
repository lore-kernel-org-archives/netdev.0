From: Jesson david <david.jesson@math.univ-toulouse.fr>
Subject: problem from netdev
Date: Tue, 27 May 2008 09:30:23 +0200
Message-ID: <483BB88F.7080407@math.univ-toulouse.fr>
Reply-To: david.jesson@math.univ-toulouse.fr
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030604040909010605020202"
Cc: david.Bonnafous@math.univ-toulouse.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.cict.fr ([195.220.59.41]:43948 "EHLO smtp1.cict.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbYE0Hy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 03:54:29 -0400
Received: from smtp1.cict.fr (localhost.localdomain [127.0.0.1])
	by smtp1.cict.fr (8.14.2/8.14.2) with ESMTP id m4R7Xdsl013836
	for <netdev@vger.kernel.org>; Tue, 27 May 2008 09:33:39 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030604040909010605020202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

hello,
i am a technical informatic french so i've a very bad english, sorry.

i've a problem for the "netdev"  parameter.
i've a dell 1950 with 4 nic, 2 onboard broadcom and 2 intel e1000.
the server boot from pxelinux with this parameter
i need to atribute eth0 to this card for a other script and i need to 
eth0 has the card of irq 17 and io 0xdcc0
> LABEL gentoo-linux-2.6.24.4-scsi
>   MENU LABEL gentoo, linux 2.6.24.4, boot scsi
>   MENU DEFAULT
>   MENU PASSWD toto
>   kernel kernel-genkernel-x86-2.6.24.4
>   # options du noyau: root, init, ramdisk_size, initrd 
> (Documentation/kernel-parameters.txt)
>   # options du script linuxrc: real_root, no..., doscsi 
> (/usr/share/genkernel/generic)
>   append softlevel=default root=/dev/ram0 init=/linuxrc 
> ramdisk_size=8192 real_root=/dev/sda6 nodhcp nogpm nohotplug nosound 
> doscsi initrd=initramfs-genkernel-x86-2.6.24.4
i tried to insert the netdev parameter :
netdev=irq=17,io=0xdcc0,name=eth0 netdev=irq=16,io=0xdce0,name=eth1  but 
after booting this parameter was not working: eth0 is not the card with 
irq=16/io=dcc0 and it the same for this other nic. ( ifconfig and lspci -v)


what is the problem ?? bad syntase or incompatible parameter ??

can you help me please ??

 

-- 

------------------------------

David Jesson
Technicien Informatique
Batiment 1R3 bureau 105
Institut de Math de Toulouse
Université Paul Sabatier
31062 Toulouse cedex 9

0661259768
056155 8888 
______________________________
                   
                                                                


--------------030604040909010605020202
Content-Type: text/x-vcard; charset=utf-8;
 name="david_jesson.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="david_jesson.vcf"

begin:vcard
fn:David Jesson
n:Jesson;David
org;quoted-printable:Universit=C3=A9 Paul Sabatier;laboratoire MIP
adr;quoted-printable:;;118 route de Narbonne;Toulouse cedex;midi-pyr=C3=A9n=C3=A9es;31062;France
email;internet:david.jesson@math.ups-tlse.fr
title:Technicien informatique
tel;work:05 61 55 88 88 
tel;fax:05 61 55 83 85
tel;cell:06 61 25 97 68
x-mozilla-html:TRUE
version:2.1
end:vcard


--------------030604040909010605020202--
