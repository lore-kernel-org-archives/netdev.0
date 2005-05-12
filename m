From: "Manfred Schwarb" <manfred99@gmx.ch>
Subject: Re: 2.4.30-hf1 do_IRQ stack overflows
Date: Thu, 12 May 2005 09:59:50 +0200 (MEST)
Message-ID: <8542.1115884790@www69.gmx.net>
References: <20050511124640.GE8541@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> The traces show huge networking execution paths.
> 
> It seems you are using some packet scheduler (CONFIG_NET_SCHED)? Pretty
> much all 
> traces show functions from sch_generic.c. Can you disable that for a test?
> 

Yes, indeed, I made some experiments with it, but do not need it urgently.
I will disable it, thanks for the hint.
And I will report back.

> > 
> > Below my three overflow messages. Would the stack reduction patches of
> Badari Pulavarty
> > help in my case? If so, I would strongly vote for inclusion into 2.4
> series!!
> 
> It has been decided that the stack reduction patches were too intrusive to
> be merged
> at this stage of v2.4 life. 
> 

OK, I got the message, I will consider upgrading to 2.6 sometime this
year...



-- 
+++ Lassen Sie Ihren Gedanken freien Lauf... z.B. per FreeSMS +++
GMX bietet bis zu 100 FreeSMS/Monat: http://www.gmx.net/de/go/mail
