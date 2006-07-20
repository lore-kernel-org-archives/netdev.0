From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL (RTAB BUG)
Date: Fri, 21 Jul 2006 03:49:01 +0400
Message-ID: <20060720234901.GA24848@ms2.inr.ac.ru>
References: <1151000966.5392.34.camel@jzny2> <1151066247.4217.254.camel@ras.pc.brisbane.lube> <1151158431.6716.95.camel@jzny2> <1153188409.13145.5.camel@ras.pc.brisbane.lube> <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube> <44BE44E3.9080100@andyfurniss.entadsl.com> <Pine.LNX.4.61.0607192114240.9570@tyr.diku.dk> <20060719210004.GB20264@ms2.inr.ac.ru> <1153374474.4231.103.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Andy Furniss <lists@andyfurniss.entadsl.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:33510 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030401AbWGTXu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 19:50:59 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
Content-Disposition: inline
In-Reply-To: <1153374474.4231.103.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> It shouldn't be.  Any decimal number can be expressed
> as a fraction, eg:

I remember this. :-) I stalled selecting corrects divisors
to fight over/underflows. Not becuase it was difficult,
just because did not see a reason to do this.



> But doing so would get rid of the table implementation 
> and the flexibility it has given us to date.  For that 
> reason I feel uncomfortable with it.
> 
> The engineering decision becomes this - are there any
> other protocols like ATM out there that could justify 
> such a change? 

Is it faster? You say, yes. Is it required? You say, yes.
Is there some protocols, which needs more flexibility? No.

> know a good deal more about them than I do.  What say
> you?

Frankly, I seriously believed that rtabs is a good way to handle ATM. :-)
I seriously believed that you have to do something like:
((packet_size+cell_payload-1)/cell_payload)*cell_size

So, if in reality even this protocol does not justify keeping ratbs, kill
them.
