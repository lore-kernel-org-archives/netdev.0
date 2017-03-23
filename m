From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 6/8] net: Commonize busy polling code to
 focus on napi_id instead of socket
Date: Thu, 23 Mar 2017 15:25:09 -0700
Message-ID: <1490307909.9687.9.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
         <20170323213749.12615.38165.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323213749.12615.38165.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-23 at 14:37 -0700, Alexander Duyck wrote:
> From: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Move the core functionality in sk_busy_loop() to napi_busy_loop() and
> make it independent of sk.
> 
> This enables re-using this function in epoll busy loop implementation.
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---

Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
