From: "David H. Lynch Jr." <dhlii@dlasys.net>
Subject: Puzzling driver problem
Date: Tue, 12 May 2009 00:13:43 -0400
Message-ID: <4A08F777.6040605@dlasys.net>
Reply-To: dhlii@dlasys.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-159.bluehost.com ([67.222.39.39]:42574 "HELO
	outbound-mail-159.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751224AbZELEUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 00:20:23 -0400
Received: from 72.25.32.200.dynamic.dejazzd.com ([72.25.32.200] helo=[206.223.20.150])
	by host200.hostmonster.com with esmtpa (Exim 4.69)
	(envelope-from <dhlii@dlasys.net>)
	id 1M3jN9-00086M-Uq
	for netdev@vger.kernel.org; Mon, 11 May 2009 22:13:44 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    I am working on a driver for the Xilinx Local Link Fifo Temac.
    It is based on an earlier driver for very similar hardware that uses
a scatter gather DMA engine rather than a FIFO.
    95% of the code is common.
    The FIFO code is also tested independently in a bootloader and works
fine there.

    The problem I am having is that after the driver and linux load.
    HTTP requests to the busy box web server hang after just a few HTTP
packets.
   
    Many other protocols seem to be working just fine. I can send
thousands of pings and get responses,
    I can SSH to the embedded linux running the driver.
    Using a packet sniffer (wireshark) aside from the HTTP stalling,
nothing looks extrodinary.
    Other packets are getting through and being replied

    I would swear the problem can not possibly be in the driver except
that if I rebuild changing only the driver
    and switching the FPGA firmware to the SDMA TEMAC everything works fine.

    I have culled through the differences between the drivers.
    I have been looking for problems like failing to free skb's or
similar resource issues.
    But those parts of both drivers are identical. The only code
differences are specific to the hardware differences.
    Nothing in the driver anywhere is sensitive or even aware of protocols.

    Has anyone seen anything like this ?
    Any suggestions as to things I might look at ?
    I am running out of ideas even for things to try.

    thank you.




-- 
Dave Lynch 					  	    DLA Systems
Software Development:  				         Embedded Linux
717.627.3770 	       dhlii@dlasys.net 	  http://www.dlasys.net
fax: 1.253.369.9244 			           Cell: 1.717.587.7774
Over 25 years' experience in platforms, languages, and technologies too numerous to list.

"Any intelligent fool can make things bigger and more complex... It takes a touch of genius - and a lot of courage to move in the opposite direction."
Albert Einstein

