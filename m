From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next PATCH v3 0/8] Add busy poll support for epoll
Date: Fri, 24 Mar 2017 19:23:36 -0700 (PDT)
Message-ID: <20170324.192336.1475562799079946827.davem@davemloft.net>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324164902.15226.48358.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 24 Mar 2017 10:07:47 -0700

> v3: Split off the code for limiting busy_poll and busy_read into a separate
>     patch for net.
>     Updated patch that changed busy loop time tracking so that it uses
>     "local_clock() >> 10" as we originally did.
>     Tweaked "Change return type.." patch by moving declaration of "work"
>     inside the loop where is was accessed and always reset to 0.
>     Added "Acked-by" for patches that received acks.

Eric, I believe Alexander has addresed your concerns.  Could you please
review patches 5 and 7 and ACK if they look ok to you?

Thanks.
