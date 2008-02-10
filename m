From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [PATCH][AX25] ax25_ds_timer: use mod_timer instead of add_timer
Date: Sun, 10 Feb 2008 19:07:58 +0100
Message-ID: <47AF3D7E.9050102@free.fr>
References: <47664A0C.4060903@free.fr> <20071218135202.GA2023@ff.dom.local> <47ADF4A2.6070705@free.fr> <20080209193905.GA2754@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Jann Traschewski <jann@gmx.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:44284 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554AbYBJSIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2008 13:08:18 -0500
In-Reply-To: <20080209193905.GA2754@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

Sorry, I should have been more explicit about the patches I applied.

My CPU is an Intel Core 2 duo and I compiled 2.6.24 with SMP option.

I applied 3 patches you have submitted for ax25 before I observed the 
possible locking.

That is :

mkiss patch
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index cfcd15a..30c9b3b 100644

[AX25] ax25_timer: use mod_timer instead of add_timer

[AX25] ax25_ds_timer: use mod_timer instead of add_timer

I also applied 4 patches for rose.ko I sent to the list a while ago.
But for this report I did not installed any ROSE driver nor application.

I will try your new patch version 2 and report any possible change.


Regards,


Bernard Pidoux,
F6BVP


Jarek Poplawski wrote:
> On Sat, Feb 09, 2008 at 07:44:50PM +0100, Bernard Pidoux F6BVP wrote:
>> Hi,
>>
>> With AX25 patches applied I still get this possible circular locking  
>> message.
> 
> Hi Bernard,
> 
> Could you confirm which exactly patches did you try? Is this vanilla
> 2.6.24 plus these two: ax25_timer and ax25_ds_timer or something more?
> And I'm not sure what do you mean by "still": the warning came back
> just after these last patches? At least these timer patches don't seem
> to change anything around locking?
> 
> Thanks for testing this,
> Jarek P.
> 
> 
