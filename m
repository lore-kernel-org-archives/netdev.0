From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Mon, 02 May 2011 13:04:19 -0600
Message-ID: <4DBF0033.2070804@genband.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com> <4DAFA9F9.5080909@hotmail.com> <4DB77D03.9070507@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>, nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:41479 "EHLO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab1EBTFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 15:05:08 -0400
In-Reply-To: <4DB77D03.9070507@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2011 08:18 PM, John Lumby wrote:

> So - question :
> is there any way, when returning from rtl8169_poll, to tell napi
> something like :
> " finish this interrupt context and let something else run on this CPU
> (always CPU0 on my machine) BUT reschedule another napi poll on this
> same device at some time after that "

Does the hardware support any options for interrupt mitigation?  I've 
used some devices where you can specify a minimum time between 
interrupts such that even if NAPI re-enabled interrupts and there were 
packets waiting the hardware would wait a certain time before raising a 
new interrupt.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
