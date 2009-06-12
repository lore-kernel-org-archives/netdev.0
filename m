From: Matthew Jakeman <matt@evolution-systems.co.uk>
Subject: ndisc_get_neigh() in Kernel Module
Date: Fri, 12 Jun 2009 17:44:46 +0100
Message-ID: <4A3285FE.50705@evolution-systems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52029 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758940AbZFLQtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 12:49:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Apologies if this is the wrong list and could someone please point me in 
the direction of a correct one if so.

I am writing a module (for kernel version 2.6.28) and I need to perform 
an IPv6 neighbour lookup on an address as I have a packet before it has 
got to the network code and had the MAC header prepended in the skbuff.

After looking about in the kernel code I came across ndisc_get_neigh() 
which seemed to suit me perfectly but I can't use it because nd_tbl is 
not exported by the kernel.

Are there any other ways for me to do the same thing that 
ndisc_get_neigh() does? I guess this is unlikely without having access 
to nd_tbl but if anyone could point me in the direction of another way 
to perform this operation it would be much appreciated.

Cheers
Matt
