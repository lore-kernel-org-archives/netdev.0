From: "Andrew Brampton" <andrew@bramp.freeserve.co.uk>
Subject: net_disable_timestamp() needed when disable SO_TIMESTAMP?
Date: Thu, 6 Mar 2008 15:55:33 -0000
Message-ID: <044f01c87fa2$844086f0$0a00a8c0@Andrew>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pih-relay05.plus.net ([212.159.14.132]:56251 "EHLO
	pih-relay05.plus.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863AbYCFQZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 11:25:21 -0500
Received: from [80.229.232.206] (helo=Andrew)
	 by pih-relay05.plus.net with smtp (Exim) id 1JXIRM-0001fq-Vs
	for netdev@vger.kernel.org; Thu, 06 Mar 2008 15:55:29 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm new to the linux kernel, but I was trying to understand how the kernel 
records timestamps for each packets and this lead me to net/core/sock.c.

Now lines 610-624 (http://lxr.linux.no/linux/net/core/sock.c#L610 ) enable 
and disable SO_TIMESTAMP, and when enabling sock_enable_timestamp(sk) is 
called to enable time stamping on the socket. However 
sock_disable_timestamp() isn't called if SO_TIMESTAMP is being disabled. I 
was wondering if that was an over sight or done on purpose?

I see that sock_disable_timestamp() is eventually called when the socket is 
freed. I thought it might not be disabled in sock.c if for example it was 
enabled elsewhere, and it was unclear if it should be disabled or not?

Thanks for any clarity on this.
Andrew

P.S If it is a bug, I'm going to prepare my first kernel patch :) 

