From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Fri, 11 Sep 2009 21:21:40 +0200
Message-ID: <4AAAA344.4030200@gmail.com>
References: <4AA82BF0.7040203@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AA82BF0.7040203@upmc.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernard Pidoux wrote, On 09/10/2009 12:28 AM:

> Hi Ralf,
> 
> Here is a set of not so frequent kernel panics captured via netconsole
> that seem related to AX25 timer. 
> 
> Regards,
> 
> Bernard Pidoux
> 

Hi Bernard,

Could/did you try to turn on this debugging option below, btw?

Regards,
Jarek P.

   CONFIG_DEBUG_OBJECTS_TIMERS:
  ?                                                                                                        ?  
  ? If you say Y here, additional code will be inserted into the                                           ?  
  ? timer routines to track the life time of timer objects and                                             ?  
  ? validate the timer operations.                                                                         ?  
  ?                                                                                                        ?  
  ? Symbol: DEBUG_OBJECTS_TIMERS [=y]                                                                      ?  
  ? Prompt: Debug timer objects                                                                            ?  
  ?   Defined at lib/Kconfig.debug:247                                                                     ?  
  ?   Depends on: DEBUG_OBJECTS                                                                            ?  
  ?   Location:                                                                                            ?  
  ?     -> Kernel hacking                                                                                  ?  
  ?       -> Kernel debugging (DEBUG_KERNEL [=y])                                                          ?  
  ?         -> Debug object operations (DEBUG_OBJECTS [=y])                                                ?  
  ?                                                                      

