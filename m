From: Rahul Hari <rahulhsaxena@gmail.com>
Subject: Re: testing techniques to confirm the effectiveness of changes made to sch_gred.c
Date: Mon, 13 Jun 2005 01:35:01 +0530
Message-ID: <4532f3170506121305327ad0f6@mail.gmail.com>
References: <4532f3170506101739702e31ad@mail.gmail.com>
	 <20050612104628.GA22463@postel.suug.ch>
Reply-To: rahul.hari@cse06.itbhu.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, netdev@vger.kernel.org, lartc-request@mailman.ds9a.nl,
        diffserv-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050612104628.GA22463@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > 1) Since the  process deals with dequeueing, i have to make changes to
> > gred_dequeue only. If t->tab[0] != 0 then  we dequeue the packet
> > otherwise do not dequeue it.
> 
> What you describe above is: only dequeue when DP 0 is configured,
> probably not what you want. The only way to prioritize within gred
> the way you want is to modify dequeue() that it iterates through
> sch->q looking for a skb with tcindex==DP0 and use it instead of
> the skb at the queue head.
> 
Thanks for the reply Thomas, 
by checking t->tab[0]!=0, the approach I wanted to follow was that "if
I have a packet in the virtual queue with DP 0, then I should not be
dequeuing any packets from the other virtual queues", ie, take no
action at all.

with best regards,
Rahul 
-- 
----------------------
"The fear you let build up in your mind is worse than the situation
that actually exists"
from "who moved my cheese"
---------------------------------------------------------------------------------
Rahul Hari
Senior Under Grad. Student,
Department of CSE,
ITBHU,
Varanasi.
Ph: +91-9845347020
rahul.hari@cse06.itbhu.org
------------------------------------------------------------------------------------------
