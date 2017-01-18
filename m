From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Wed, 18 Jan 2017 12:32:07 -0500 (EST)
Message-ID: <20170118.123207.53777509111948450.davem@davemloft.net>
References: <20170113.121407.448230751444957957.davem@davemloft.net>
        <CALzJLG_fjiGyuB_buZqOSMU7SaCnuqFiZ0UyW+hPDq+3yx7TWg@mail.gmail.com>
        <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG--ZRVk0Zy+6UaGCWbOhki+PZnkmrh9rjojU1ZDm_5Y6w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Mon, 16 Jan 2017 22:30:29 +0200

>> But please bear with me here, what if we queue this patch up to -stable ?

You've got to be seriously kidding me that your idea is to submit an
incredibly diruptive driver rename to -stable to solve this problem.

That is completely a non-starter.

The whole idea is to _MINIMIZE_ the amount of change happening in
-stable in order to avoid regressions and negative consequence for
everyone using the -stable tree.

I am strongly against a major reorganization of this driver, sorry.
The Synopsys folks want to do the same thing for the stmmac driver,
for even more nefarious reasons, and I'm rejecting all of their
attempts to do that as well.

If you look in that thread, they said they would "help" with the
-stable backports, and in there I explained why that is a completely
empty gesture.  There are people doing the backports outside of your
spehere of influence, who need to get their work done "right now" and
aren't going to consult you and be on your schedule for doing those
backports.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
