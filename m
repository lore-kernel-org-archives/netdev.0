From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Subject: i386 vs x86_64 struct tpacket_hdr layout
Date: Fri, 20 Dec 2013 14:30:06 +0100
Message-ID: <52B4465E.2090904@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mika.eatserver.nl ([195.20.9.75]:59430 "EHLO mika.eatserver.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030189Ab3LTOBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 09:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm compiling my 32bit application with -m32 on a x86_64 system/kernel.

Things aren't working because for my application tp_len is at offset 4
but for the kernel it is at offset 8.

struct tpacket_hdr {
         unsigned long   tp_status;
         unsigned int    tp_len;
         unsigned int    tp_snaplen;
         unsigned short  tp_mac;
         unsigned short  tp_net;
         unsigned int    tp_sec;
         unsigned int    tp_usec;
};

How is this suppose to work ?

thanks,
Norbert van Bolhuis
