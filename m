From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][NETNS]: Fix arbitrary net_device-s corruptions on net_ns
 stop.
Date: Wed, 07 May 2008 19:37:55 +0400
Message-ID: <4821CCD3.5020502@openvz.org>
References: <48216398.9050509@openvz.org> <4821CBE5.5090801@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49656 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070AbYEGPnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 11:43:22 -0400
In-Reply-To: <4821CBE5.5090801@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +		sprintf(fb_name, "dev%d", dev->ifindex);
> 
> The computed interface name can not exceed IFNAMSIZ, 3 ('dev') + 10 (max 
> int) + 1 ('\0'). In this case there is no risk to corrupt the stack but 
> may be it is more secure to change that to snprintf(fb_name, IFNAMSIZ, 
> "dev%d", dev->ifindex), just in case, no ?

But you have just noticed, that "there is no risk to corrupt the stack"!
What else can be "more secure" then :) ?

Thanks,
Pavel
