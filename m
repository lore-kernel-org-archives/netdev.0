From: Or Gerlitz <ogerlitz-hKgKHo2Ms0FWk0Htik3J/w@public.gmane.org>
Subject: Re: net-next pull request: RDS
Date: Sun, 12 Sep 2010 10:49:38 +0200
Message-ID: <4C8C9422.2070306@Voltaire.com>
References: <4C892C9C.4060304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, RDS Devel <rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C892C9C.4060304-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andy, 

Some clarifications/questions from whatever quick look one can have over 107 patches...

Zach Brown's "RDS/IB: print IB event strings as well as their number" - commit
1bde04a63d532c2540d6fdee0a661530a62b1686 in net-next-2.6 looks perfect to reside as a helper function in the core IB stack which can be in use by other rdma drivers (e.g ipoib, iser, srp, etc). 

Chris Mason's "rds: recycle FMRs through lockless lists added net/rds/xlist.h" - 6fa70da6081bbcf948801fd5ee0be4d222298a43 adds net/rds/xlist.h - isn't this something that better be placed under include/linux/. etc?

And last, your "RDS/IB: add _to_node() macros for numa and use {k,v}malloc_node()" patch looks interesting, 1st, it has some macros which could be placed in more general locations e.g pcidev_to_node and ibdev_to_node, your "significantly helps performance" comment is interesting, I'll send a separate note about that to the rdma mailing list.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
