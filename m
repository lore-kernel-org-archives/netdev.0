From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 2/8] tcp: Record Rx hash and NAPI ID in
 tcp_child_process
Date: Thu, 23 Mar 2017 18:00:50 -0700
Message-ID: <1490317250.9687.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
         <20170323213644.12615.27158.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323213644.12615.27158.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-23 at 14:36 -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> While working on some recent busy poll changes we found that child sockets
> were being instantiated without NAPI ID being set.  In our first attempt to
> fix it, it was suggested that we should just pull programming the NAPI ID
> into the function itself since all callers will need to have it set.
> 
> In addition to the NAPI ID change I have dropped the code that was
> populating the Rx hash since it was actually being populated in
> tcp_get_cookie_sock.
> 
> Reported-by: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Suggested-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---

Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
