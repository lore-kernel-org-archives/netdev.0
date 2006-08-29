From: "Frank Schneider" <twodipu@hotmail.com>
Subject: dealing with "hard_start_xmit " of net_device
Date: Tue, 29 Aug 2006 18:29:45 +0200
Message-ID: <BAY101-F40009ADA5F216D0E5B791BAB390@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s11.bay0.hotmail.com ([65.54.246.83]:15196 "EHLO
	bay0-omc1-s11.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S964974AbWH2Q3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 12:29:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


hi all,

I am customizing a linux driver code of WLAN card as Access Point on Linux 
kernel 2.6.12 to work with.

We know struct net_device has a member pointer to a method called
hard_start_xmit that initiates the transmission through the device. Data 
should contain sk_buff structure.

For that particular device, the whole driver code is consists of some 
modules. Among those one module already assigned a function to this pointer 
"hard_start_xmit". I already tested its working well to transmit outgoing 
data frame from AP.
My question is, how can I assign another function in different module. I 
need to call this function when transmit data frame, but in practice, this 
function will not send any data frame, e.g. won’t use dev_queue_xmit.
You can assume, when something to  transmit it will call two functions in 
two modules of same driver

Any suggestions to do that please ?



regards,
/ Frank

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/

