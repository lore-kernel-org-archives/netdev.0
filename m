From: Andrew Kohlsmith <akohlsmith@mixdown.ca>
Subject: Re: 2.6.10 and HTB dequeue bug
Date: Wed, 2 Mar 2005 13:50:11 -0500
Message-ID: <200503021350.11588.akohlsmith@mixdown.ca>
References: <200503011403.07243.akohlsmith@mixdown.ca> <4224FEAF.2090209@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <4224FEAF.2090209@tpack.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On March 1, 2005 06:45 pm, Tommy Christensen wrote:
> An overflow of q->direct_queue (in htb_enqueue) seems to offset
> sch->q.qlen. Probably this is what's causing htb_dequeue to complain.

Got a couple more of these in the last 12h:

HTB: dequeue bug (8,204417247,204417247), report it please !
htb*g j=204417247 lj=204417247
htb*r7 m=0
htb*r6 m=0
htb*r5 m=0
htb*r4 m=0
htb*r3 m=0
htb*r2 m=0
htb*r1 m=0
htb*r0 m=0
htb*c10001 m=2 t=25845 c=25845 pq=0 df=50061 ql=0 pa=0 f:
htb*c10010 m=2 t=295682 c=27708 pq=0 df=254102 ql=0 pa=0 f:
htb*c10020 m=2 t=77441 c=28542 pq=0 df=13990637 ql=0 pa=0 f:
htb*c10030 m=2 t=77441 c=28542 pq=0 df=50061 ql=0 pa=0 f:
htb*c10040 m=2 t=303504 c=28402 pq=0 df=337098 ql=0 pa=0 f:
htb*c10050 m=2 t=-122209 c=28402 pq=0 df=123725 ql=0 pa=0 f:

and

HTB: dequeue bug (8,204418247,204418247), report it please !
htb*g j=204418247 lj=204418247
htb*r7 m=0
htb*r6 m=0
htb*r5 m=0
htb*r4 m=0
htb*r3 m=0
htb*r2 m=0
htb*r1 m=0
htb*r0 m=0
htb*c10001 m=2 t=23769 c=23769 pq=0 df=41413 ql=0 pa=0 f:
htb*c10010 m=2 t=295682 c=27708 pq=0 df=237057 ql=0 pa=0 f:
htb*c10020 m=2 t=77441 c=28542 pq=0 df=15556450 ql=0 pa=0 f:
htb*c10030 m=2 t=70844 c=26230 pq=0 df=41413 ql=0 pa=0 f:
htb*c10040 m=2 t=303504 c=28402 pq=0 df=532505 ql=0 pa=0 f:
htb*c10050 m=2 t=283166 c=26595 pq=0 df=702201 ql=0 pa=0 f:

Just posting them in case they can help.  The archives for this list don't 
seem to be showing my messages and I'm not (yet) subscribed, so please CC any 
replies directly.

Regards,
Andrew
