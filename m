From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] cgroup: Provide empty definition of
 task_cgroup_path()
Date: Wed, 12 Mar 2014 15:00:20 -0400 (EDT)
Message-ID: <20140312.150020.340861233360073600.davem@davemloft.net>
References: <1394649942-5854-1-git-send-email-vgoyal@redhat.com>
	<1394649942-5854-2-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394649942-5854-2-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 12 Mar 2014 14:45:41 -0400

> Compilation with !CONFIG_CGROUP fails for task_cgroup_path() user. So
> provide an emtpy definition.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/cgroup.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 9450f02..bf40adb 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -869,6 +869,8 @@ static inline int cgroup_attach_task_all(struct task_struct *from,
>  	return 0;
>  }
>  
> +static inline int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen) {return 0;}
> +

Please properly format this just like any other function.

static inline int task_cgroup_path(struct task_struct *task, char *buf, size_t buflen)
{
	eturn 0;
}

It looked like a plain static declaration on first glance.
