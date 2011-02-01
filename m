From: Rick Jones <rick.jones2@hp.com>
Subject: Re: How To Temporarily Suspend Network Traffic
Date: Tue, 01 Feb 2011 09:32:32 -0800
Message-ID: <4D4843B0.1090803@hp.com>
References: <87d3nbakwx.fsf@alamut.ozu.edu.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Volkan YAZICI <volkan.yazici@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:34405 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752403Ab1BARcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 12:32:35 -0500
In-Reply-To: <87d3nbakwx.fsf@alamut.ozu.edu.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Volkan YAZICI wrote:
> Hi,
> 
> I want to temporarily suspend the network traffic on a particular
> interface -- if possible, in microsecond granularity. For this purpose,
> ifup/ifdown ioctl() calls doesn't work. That is, for wireless
> interfaces, connection isn't get recovered; for wired interfaces, it
> takes at least 2 seconds to recover. I tried using tc, but it doesn't
> accept "rate 0" parameter. Neither "iwconfig wlan0 rate 0" has any
> effect. (Moreover, in iwconfig manual it is told that values below 1000
> are card specific and are usually an index in the bit-rate list.) Do you
> have any suggestions? Can you recommend me to check any code piece in
> the kernel or some other tool?

Out of not quite idle curiousity, what are you trying to accomplish?

Instead of using tc to set a zero rate, you could perhaps try using tc to set a 
delay?  If it doesn't offer microseconds of delay, pehaps setting a delay and 
then eliminating it after your own pause will do what you want - depends of 
course on what it is  you really want.  Your saying you wanted microsecond 
granularity suggests you don't want to suspend traffic for very long?

rick jones

> 
> Regards.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

