From: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH] random: seed random_int_secret at least poorly at
 core_initcall time
Date: Fri, 15 Nov 2013 16:05:20 -0500
Message-ID: <20131115210520.GA16722@thunk.org>
References: <cover.1384160397.git.dborkman@redhat.com>
 <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
 <20131111134357.GC10104@thunk.org>
 <20131112000307.GB14929@order.stressinduktion.org>
 <20131112115350.GA14077@thunk.org>
 <20131112131627.GD14929@order.stressinduktion.org>
 <20131112134603.GE14929@order.stressinduktion.org>
 <20131114025448.GB31602@thunk.org>
 <CAGXu5j+ySEdQBXKkspYC=svfekBja2Z_2tcWSAOEbvyiMLf=aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, Florian Weimer <fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5j+ySEdQBXKkspYC=svfekBja2Z_2tcWSAOEbvyiMLf=aA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 15, 2013 at 10:33:04AM -0800, Kees Cook wrote:
> 
> When the static stack canary was mentioned during the ARM summit, I
> dug around a little bit and saw that at very early boot, yes, it was
> always the same, but after boot finished, it was different from boot
> to boot. I didn't get far enough to figure out what was changing it
> later on.

I've been in Seoul this past week, so I haven't had a chance look more
closely at this, but what's not clear to me what the impact will be of
having a static statck canary during early boot.  Does that mean the
stack canary for the certain kernel threads and the pid 1 are always
constant, since their stacks are getting set up before we're actually
able to initialize the stack canary with something random?

     		       	     	    	 - Ted
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
