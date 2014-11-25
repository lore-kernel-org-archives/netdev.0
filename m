From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 12:13:05 -0500 (EST)
Message-ID: <20141125.121305.2094097848188324942.davem@davemloft.net>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
	<5474ABB6.3030400@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
	fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org,
	hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, iulia.manda21-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, JBeulich-IBi9RG/b67k@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mcgrof-IBi9RG/b67k@public.gmane.org, mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org,
	mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Paul.Durrant-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org,
	paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
	willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	zhe
To: rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5474ABB6.3030400-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date: Tue, 25 Nov 2014 08:17:58 -0800

> Is the splice family of syscalls the only one that tiny has identified
> for optional building or can we expect similar treatment for other
> syscalls?
> 
> Why will many embedded systems not need these syscalls?  You know
> exactly what apps they run and you are positive that those apps do
> not use splice?

I think starting to compile out system calls is a very slippery
slope we should not begin the journey down.

This changes the forward facing interface to userspace.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
