From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 14:27:41 -0500 (EST)
Message-ID: <20141125.142741.1620673255148724338.davem@davemloft.net>
References: <20141125185310.GA24891@cloud>
	<20141125.140441.401150380839514113.davem@davemloft.net>
	<87egsr9jkz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org,
	catalina.mocanu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org,
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
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87egsr9jkz.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Tue, 25 Nov 2014 13:16:44 -0600

> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> 
>> From: josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
>> Date: Tue, 25 Nov 2014 10:53:10 -0800
>>
>>> It's not a "slippery slope"; it's been our standard practice for ages.
>>
>> We've never put an entire class of generic system calls behind
>> a config option.
> 
> CONFIG_SYSVIPC has been in the kernel as long as I can remember.
> 
> I seem to remember a plan to remove that code once userspace had
> finished migrating to more unixy interfaces to ipc.  But in 20 years
> that migration does does not seem to have finished, or even look
> like it ever will.
> 
> But if we started a slippery slope it was long long ago.

Fair enough.

Would be amusing if these tiny systems have it enabled.
