From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Tue, 25 May 2004 02:07:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405250207.58376.dtor_core@ameritech.net>
References: <20040524215346.73109.qmail@web80501.mail.yahoo.com> <1085436571.1041.69.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jaume Catarineu <jaume.catarineu@upf.edu>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1085436571.1041.69.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 24 May 2004 05:09 pm, jamal wrote:
> On Mon, 2004-05-24 at 17:53, Dmitry Torokhov wrote:
> 
> 
> > It just does... 
> 
> you mean just "because" ? ;-> Semantics allow you to do more.
> 
> > TBF as far as I understand is a simple rate
> > limiting tool for your network link. 
> 
> Consider it a scheduler really.
> 
> > I implemented the child
> > qdisc for TBF so you can change default fifo queue in it to
> > SFQ or PRIO. It supposed to be very lightweight. If you need
> > something more complex/fancy then you probably want HTB or CBF.
> 
> Ok, I thought you were trying to hierachical token buckets. Why coulnt
> you go the extra step?
> In any case, i agree what you have is a lightweight improvement; but you
> could go the next mile.
> Your original patch should be sufficient in the case you just want to
> stay there.
> 

Yes, I think we should stay right here. If we go that next mile we will
get HTB and we already have a decent implementation ;)

-- 
Dmitry
