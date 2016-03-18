From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Outreachy kernel] [PATCH v2] iwlwifi: dvm: use
 alloc_ordered_workqueue()
Date: Fri, 18 Mar 2016 16:47:44 -0400
Message-ID: <20160318204744.GN20028@mtj.duckdns.org>
References: <1458231561-13184-1-git-send-email-eraretuya@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1458231561-13184-1-git-send-email-eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2016 at 12:19:21AM +0800, Eva Rachel Retuya wrote:
> Use alloc_ordered_workqueue() to allocate the workqueue instead of
> create_singlethread_workqueue() since the latter is deprecated and is scheduled
> for removal.
> 
> There are work items doing related operations that shouldn't be swapped when
> queued in a certain order hence preserve the strict execution ordering of a
> single threaded (ST) workqueue by switching to alloc_ordered_workqueue().
> 
> WQ_MEM_RECLAIM flag is not needed since the worker is not supposed to free
> memory.

I think "not depended during memory reclaim" probalby is a better way
to describe it.

> Signed-off-by: Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

But other than that,

 Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
