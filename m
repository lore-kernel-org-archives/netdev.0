From: glee@gnupilgrims.org
Subject: Re: [PATCH] connect() return value.
Date: Thu, 15 Aug 2002 11:25:43 +0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020815032543.GA3083@gandalf.chinesecodefoo.org>
References: <20020814045755.GB32315@anakin.wychk.org> <200208141725.VAA24463@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200208141725.VAA24463@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Wed, Aug 14, 2002 at 09:25:39PM +0400, kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > So, in the near future, we can expect Linux to not return 0 for
> > non-blocking connects (i.e. the change you mentioned)?
> 
> I wanted, but I changed my opinion about this. It is pretty strange to mimic
> behavior of solaris/tru64 and Co, which is really stinking.
> 

It is true it is bad to go for a technically inferior solution that
EINTR must be handled by the userspace code.

> So, despite of our current behavior is not perfect and even not
> quite self-consistent, it is the best one. Well, and it does not
> contradict to sus/posix.
>


Agreed for both points, as far as I recall it is not standardized,
not even what "may" or "should" be done.


> So, connect() remains restartable, and it will return 0 on success
> instead of EISCONN crap.


Yep.

I research how sockets are done on various Unix as a hobby. So, 
one of the motives of my original letter was that I wanted to know
whether there is any special reasons (well now I know after this 
discussion) why Linux's connect is restartable. 

I will make a special note of that in my notes.

Thanks for this fruitful discussion. :-)



	-- G.
	
