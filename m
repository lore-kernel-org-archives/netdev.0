From: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 06/23] usb-gadget/ether: use per-attribute show and store
 methods
Date: Mon, 28 Sep 2015 13:40:30 +0200
Message-ID: <5609272E.20702@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-7-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pratyush Anand <pratyush.anand-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Joel Becker <jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1443189000-13398-7-git-send-email-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

> ---
>   drivers/usb/gadget/function/f_ecm.c            |  8 ++---
>   drivers/usb/gadget/function/f_eem.c            |  8 ++---
>   drivers/usb/gadget/function/f_ncm.c            |  8 ++---
>   drivers/usb/gadget/function/f_rndis.c          |  8 ++---
>   drivers/usb/gadget/function/f_subset.c         |  8 ++---
>   drivers/usb/gadget/function/u_ether_configfs.h | 44 +++++++++++---------------
>   6 files changed, 38 insertions(+), 46 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_ecm.c b/drivers/usb/gadget/function/f_ecm.c
> index 7b7424f..0106de8 100644
> --- a/drivers/usb/gadget/function/f_ecm.c
> +++ b/drivers/usb/gadget/function/f_ecm.c
> @@ -855,10 +855,10 @@ USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(ecm);
>   USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(ecm);
>
>   static struct configfs_attribute *ecm_attrs[] = {
> -	&f_ecm_opts_dev_addr.attr,
> -	&f_ecm_opts_host_addr.attr,
> -	&f_ecm_opts_qmult.attr,
> -	&f_ecm_opts_ifname.attr,
> +	&ecm_opts_attr_dev_addr,
> +	&ecm_opts_attr_host_addr,
> +	&ecm_opts_attr_qmult,
> +	&ecm_opts_attr_ifname,
>   	NULL,
>   };
>
> diff --git a/drivers/usb/gadget/function/f_eem.c b/drivers/usb/gadget/function/f_eem.c
> index c9e90de..f965403 100644
> --- a/drivers/usb/gadget/function/f_eem.c
> +++ b/drivers/usb/gadget/function/f_eem.c
> @@ -555,10 +555,10 @@ USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(eem);
>   USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(eem);
>
>   static struct configfs_attribute *eem_attrs[] = {
> -	&f_eem_opts_dev_addr.attr,
> -	&f_eem_opts_host_addr.attr,
> -	&f_eem_opts_qmult.attr,
> -	&f_eem_opts_ifname.attr,
> +	&eem_opts_attr_dev_addr,
> +	&eem_opts_attr_host_addr,
> +	&eem_opts_attr_qmult,
> +	&eem_opts_attr_ifname,
>   	NULL,
>   };
>
> diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
> index 3f05c6bd..01a99e5 100644
> --- a/drivers/usb/gadget/function/f_ncm.c
> +++ b/drivers/usb/gadget/function/f_ncm.c
> @@ -1503,10 +1503,10 @@ USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(ncm);
>   USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(ncm);
>
>   static struct configfs_attribute *ncm_attrs[] = {
> -	&f_ncm_opts_dev_addr.attr,
> -	&f_ncm_opts_host_addr.attr,
> -	&f_ncm_opts_qmult.attr,
> -	&f_ncm_opts_ifname.attr,
> +	&ncm_opts_attr_dev_addr,
> +	&ncm_opts_attr_host_addr,
> +	&ncm_opts_attr_qmult,
> +	&ncm_opts_attr_ifname,
>   	NULL,
>   };
>
> diff --git a/drivers/usb/gadget/function/f_rndis.c b/drivers/usb/gadget/function/f_rndis.c
> index 32985da..a04b526 100644
> --- a/drivers/usb/gadget/function/f_rndis.c
> +++ b/drivers/usb/gadget/function/f_rndis.c
> @@ -878,10 +878,10 @@ USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(rndis);
>   USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(rndis);
>
>   static struct configfs_attribute *rndis_attrs[] = {
> -	&f_rndis_opts_dev_addr.attr,
> -	&f_rndis_opts_host_addr.attr,
> -	&f_rndis_opts_qmult.attr,
> -	&f_rndis_opts_ifname.attr,
> +	&rndis_opts_attr_dev_addr,
> +	&rndis_opts_attr_host_addr,
> +	&rndis_opts_attr_qmult,
> +	&rndis_opts_attr_ifname,
>   	NULL,
>   };
>
> diff --git a/drivers/usb/gadget/function/f_subset.c b/drivers/usb/gadget/function/f_subset.c
> index e3dfa67..055e4ea 100644
> --- a/drivers/usb/gadget/function/f_subset.c
> +++ b/drivers/usb/gadget/function/f_subset.c
> @@ -413,10 +413,10 @@ USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(gether);
>   USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(gether);
>
>   static struct configfs_attribute *gether_attrs[] = {
> -	&f_gether_opts_dev_addr.attr,
> -	&f_gether_opts_host_addr.attr,
> -	&f_gether_opts_qmult.attr,
> -	&f_gether_opts_ifname.attr,
> +	&gether_opts_attr_dev_addr,
> +	&gether_opts_attr_host_addr,
> +	&gether_opts_attr_qmult,
> +	&gether_opts_attr_ifname,
>   	NULL,
>   };
>
> diff --git a/drivers/usb/gadget/function/u_ether_configfs.h b/drivers/usb/gadget/function/u_ether_configfs.h
> index bcbd301..4f47289 100644
> --- a/drivers/usb/gadget/function/u_ether_configfs.h
> +++ b/drivers/usb/gadget/function/u_ether_configfs.h
> @@ -17,9 +17,6 @@
>   #define __U_ETHER_CONFIGFS_H
>
>   #define USB_ETHERNET_CONFIGFS_ITEM(_f_)					\
> -	CONFIGFS_ATTR_STRUCT(f_##_f_##_opts);				\
> -	CONFIGFS_ATTR_OPS(f_##_f_##_opts);				\
> -									\
>   	static void _f_##_attr_release(struct config_item *item)	\
>   	{								\
>   		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
> @@ -29,14 +26,13 @@
>   									\
>   	static struct configfs_item_operations _f_##_item_ops = {	\
>   		.release	= _f_##_attr_release,			\
> -		.show_attribute = f_##_f_##_opts_attr_show,		\
> -		.store_attribute = f_##_f_##_opts_attr_store,		\
>   	}
>
>   #define USB_ETHERNET_CONFIGFS_ITEM_ATTR_DEV_ADDR(_f_)			\
> -	static ssize_t _f_##_opts_dev_addr_show(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_dev_addr_show(struct config_item *item, \
>   						char *page)		\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		int result;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -46,9 +42,10 @@
>   		return result;						\
>   	}								\
>   									\
> -	static ssize_t _f_##_opts_dev_addr_store(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_dev_addr_store(struct config_item *item, \
>   						 const char *page, size_t len)\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		int ret;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -64,15 +61,13 @@
>   		return ret;						\
>   	}								\
>   									\
> -	static struct f_##_f_##_opts_attribute f_##_f_##_opts_dev_addr = \
> -		__CONFIGFS_ATTR(dev_addr, S_IRUGO | S_IWUSR,		\
> -				_f_##_opts_dev_addr_show,		\
> -				_f_##_opts_dev_addr_store)
> +	CONFIGFS_ATTR(_f_##_opts_, dev_addr)
>
>   #define USB_ETHERNET_CONFIGFS_ITEM_ATTR_HOST_ADDR(_f_)			\
> -	static ssize_t _f_##_opts_host_addr_show(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_host_addr_show(struct config_item *item, \
>   						 char *page)		\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		int result;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -82,9 +77,10 @@
>   		return result;						\
>   	}								\
>   									\
> -	static ssize_t _f_##_opts_host_addr_store(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_host_addr_store(struct config_item *item, \
>   						  const char *page, size_t len)\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		int ret;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -100,15 +96,13 @@
>   		return ret;						\
>   	}								\
>   									\
> -	static struct f_##_f_##_opts_attribute f_##_f_##_opts_host_addr = \
> -		__CONFIGFS_ATTR(host_addr, S_IRUGO | S_IWUSR,		\
> -				_f_##_opts_host_addr_show,		\
> -				_f_##_opts_host_addr_store)
> +	CONFIGFS_ATTR(_f_##_opts_, host_addr)
>
>   #define USB_ETHERNET_CONFIGFS_ITEM_ATTR_QMULT(_f_)			\
> -	static ssize_t _f_##_opts_qmult_show(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_qmult_show(struct config_item *item,	\
>   					     char *page)		\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		unsigned qmult;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -117,9 +111,10 @@
>   		return sprintf(page, "%d", qmult);			\
>   	}								\
>   									\
> -	static ssize_t _f_##_opts_qmult_store(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_qmult_store(struct config_item *item, \
>   					      const char *page, size_t len)\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		u8 val;							\
>   		int ret;						\
>   									\
> @@ -140,15 +135,13 @@ out:									\
>   		return ret;						\
>   	}								\
>   									\
> -	static struct f_##_f_##_opts_attribute f_##_f_##_opts_qmult =	\
> -		__CONFIGFS_ATTR(qmult, S_IRUGO | S_IWUSR,		\
> -				_f_##_opts_qmult_show,		\
> -				_f_##_opts_qmult_store)
> +	CONFIGFS_ATTR(_f_##_opts_, qmult)
>
>   #define USB_ETHERNET_CONFIGFS_ITEM_ATTR_IFNAME(_f_)			\
> -	static ssize_t _f_##_opts_ifname_show(struct f_##_f_##_opts *opts, \
> +	static ssize_t _f_##_opts_ifname_show(struct config_item *item, \
>   					      char *page)		\
>   	{								\
> +		struct f_##_f_##_opts *opts = to_f_##_f_##_opts(item);	\
>   		int ret;						\
>   									\
>   		mutex_lock(&opts->lock);				\
> @@ -158,7 +151,6 @@ out:									\
>   		return ret;						\
>   	}								\
>   									\
> -	static struct f_##_f_##_opts_attribute f_##_f_##_opts_ifname =	\
> -		__CONFIGFS_ATTR_RO(ifname, _f_##_opts_ifname_show)
> +	CONFIGFS_ATTR_RO(_f_##_opts_, ifname)
>
>   #endif /* __U_ETHER_CONFIGFS_H */
>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
