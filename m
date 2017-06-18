From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Sun, 18 Jun 2017 12:29:01 -0400 (EDT)
Message-ID: <20170618.122901.124548969151925362.davem@davemloft.net>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170618115035.2156-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Sun, 18 Jun 2017 14:50:28 +0300

> Changes from previous versions
> ------------------------------
>  - V2: Add several inclusion into qede_rdma.h to have proper declarations
>    of all variable types used in it

I'm still not happy at all.

You failed the address the specific thing I asked to be fixed.

In patch #4, the rename, you just say in your commit message
that you are "renaming".

But in the qedr/main.c part of the change, you are _REMOVING_
the include.

And I said that can't be right if all you are doing is renaming the
files.

So either fix that part of the change to actually rename the include
header, rather than removing the include, or explain _IN DETAIL_ in
the commit log message why removing it is the right thing to do and
especially _WHY_ it is appropriate for it to be done as part of the
renaming patch.

Can you understand how inconsistent it is to have a patch that says
nothing more than "I'm renaming files" and yet have other stuff
happening?

THanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
