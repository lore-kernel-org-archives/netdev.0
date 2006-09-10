From: =?UTF-8?Q?mwitosz-linux?= <mwitosz-linux@o2.pl>
Subject: =?UTF-8?Q?problem=20with=20DMA=20when=20writting=20driver=20for=20?=
	=?UTF-8?Q?rtl8139=3F?=
Date: Sun, 10 Sep 2006 15:46:15 +0200
Message-ID: <42107d89.2f8aa3f2.45041727.950e9@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from rekin26.go2.pl ([193.17.41.76]:63447 "EHLO rekin22.go2.pl")
	by vger.kernel.org with ESMTP id S932175AbWIJNqQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 09:46:16 -0400
Received: from o2.pl (unknown [10.0.0.65])
	by rekin22.go2.pl (Postfix) with SMTP id 95AB05BD4C
	for <netdev@vger.kernel.org>; Sun, 10 Sep 2006 15:46:15 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi, everybody
my name is Mariusz, I am newbie to linux kernel, 
For several weeks I have been writing kernel driver for network card based on 
rtl8139c chip. I am writing this driver for micrococontrollers technology course in my university

I have some problems with DMA, i suppose.

there is a bit in Transmit Status Descriptor of RTL8139c which after clearing(It must be cleared to 
start transmit operation) shouldb be placed in 1 state - which according to RTL8139 specification means that 
DMA copy from memory to internal RTL fifo has finished.

The problem is: rtl doesn't clear this bit

I use  pci_map_single to map address of packet buffer to dma capable memory, then cpu_to_le32 to get physicall
address of this buffer. 

Do you have any idea what may work wrong?

here is my code:
1) rtlmodule contains functions related to initialization issues
2) rtlopen contains functions related to open device issues and interrupt handling
3) rtltransmit contains functions related to transmision issues

and here is output from kernel

best regards, 
Mariusz Witosz
