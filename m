From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v3 5/8] net: Track start of busy loop instead
 of when it should end
Date: Fri, 24 Mar 2017 20:34:15 -0700
Message-ID: <1490412855.24891.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
         <20170324170818.15226.51326.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324170818.15226.51326.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-24 at 10:08 -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> This patch flips the logic we were using to determine if the busy polling
> has timed out.  The main motivation for this is that we will need to
> support two different possible timeout values in the future and by
> recording the start time rather than when we would want to end we can focus
> on making the end_time specific to the task be it epoll or socket based
> polling.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---


Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks guys !
