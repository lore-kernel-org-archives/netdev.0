From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 18:17:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626085307.096652C0B4@lists.samba.org>
References: <20030625.205941.41631020.davem@redhat.com>
Cc: paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Wed, 25 Jun 2003 20:59:41 MST."
             <20030625.205941.41631020.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030625.205941.41631020.davem@redhat.com> you write:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Thu, 26 Jun 2003 13:57:09 +1000
>    
>    Frankly, I'm amazed anyone sees reordering in real life...
> 
> Many paths on the internet are quite reordered, this is
> the first thing.  In fact, I claim that any TCP stack that
> doesn't do reordering detection is busted performance wise.

Sure, but I was assuming that the packets arrived in order and got
processed out of order.  If the first one isn't happening, this patch
is doubly useless 8)

Thanks,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
