From: hayeswang <hayeswang@realtek.com>
Subject: RE: r8169 :  always copying the rx buffer to new skb
Date: Tue, 3 May 2011 19:59:05 +0800
Message-ID: <3191E98898F04B88AE6C7E944DC28DA4@realtek.com.tw>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com> <4DAFA9F9.5080909@hotmail.com> <4DB77D03.9070507@hotmail.com> <4DBF0033.2070804@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Francois Romieu' <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	'Ben Hutchings' <bhutchings@solarflare.com>
To: 'Chris Friesen' <chris.friesen@genband.com>,
	'John Lumby' <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:33419 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab1ECL7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 07:59:21 -0400
In-Reply-To: <4DBF0033.2070804@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Chris Friesen [mailto:chris.friesen@genband.com] 
> Sent: Tuesday, May 03, 2011 3:04 AM
> To: John Lumby
> Cc: Francois Romieu; netdev@vger.kernel.org; Ben Hutchings; nic_swsd
> Subject: Re: r8169 : always copying the rx buffer to new skb
> 
> On 04/26/2011 08:18 PM, John Lumby wrote:
> 
> > So - question :
> > is there any way, when returning from rtl8169_poll, to tell napi 
> > something like :
> > " finish this interrupt context and let something else run 
> on this CPU 
> > (always CPU0 on my machine) BUT reschedule another napi 
> poll on this 
> > same device at some time after that "
> 
> Does the hardware support any options for interrupt 
> mitigation?  I've used some devices where you can specify a 
> minimum time between interrupts such that even if NAPI 
> re-enabled interrupts and there were packets waiting the 
> hardware would wait a certain time before raising a new interrupt.
> 

Yes, please refer to the register 0xE2 of datasheet. And the time is influenced
by the register 0xE0.

 
Best Regards,
Hayes

