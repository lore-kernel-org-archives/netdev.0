From: Shanker Wang <shankerwangmiao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0786/1285] Replace numeric parameter like 0444 with macro
Date: Tue, 2 Aug 2016 23:50:02 +0800
Message-ID: <E31420B0-890A-4B6B-99D6-9230924886D6@gmail.com>
References: <20160802114618.2152-1-baolex.ni@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org,
	m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160802114618.2152-1-baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I don’t think macros is clearer, and the meaning of those so called 
“magic numbers” like 0644 is clear enough. People are used to that.
As a result, it is not meaningful to replace them with macro.


> 在 2016年8月2日，19:46，Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> 写道：
> 
> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
> 
> Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
> drivers/net/wireless/marvell/libertas/mesh.c | 20 ++++++++++----------
> 1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
> index d0c881d..ae4f0a5 100644
> --- a/drivers/net/wireless/marvell/libertas/mesh.c
> +++ b/drivers/net/wireless/marvell/libertas/mesh.c
> @@ -297,19 +297,19 @@ static ssize_t lbs_mesh_set(struct device *dev,
>  * lbs_mesh attribute to be exported per ethX interface
>  * through sysfs (/sys/class/net/ethX/lbs_mesh)
>  */
> -static DEVICE_ATTR(lbs_mesh, 0644, lbs_mesh_get, lbs_mesh_set);
> +static DEVICE_ATTR(lbs_mesh, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, lbs_mesh_get, lbs_mesh_set);
> 
> /*
>  * anycast_mask attribute to be exported per mshX interface
>  * through sysfs (/sys/class/net/mshX/anycast_mask)
>  */
> -static DEVICE_ATTR(anycast_mask, 0644, lbs_anycast_get, lbs_anycast_set);
> +static DEVICE_ATTR(anycast_mask, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, lbs_anycast_get, lbs_anycast_set);
> 
> /*
>  * prb_rsp_limit attribute to be exported per mshX interface
>  * through sysfs (/sys/class/net/mshX/prb_rsp_limit)
>  */
> -static DEVICE_ATTR(prb_rsp_limit, 0644, lbs_prb_rsp_limit_get,
> +static DEVICE_ATTR(prb_rsp_limit, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, lbs_prb_rsp_limit_get,
> 		lbs_prb_rsp_limit_set);
> 
> static struct attribute *lbs_mesh_sysfs_entries[] = {
> @@ -764,13 +764,13 @@ static ssize_t capability_set(struct device *dev, struct device_attribute *attr,
> }
> 
> 
> -static DEVICE_ATTR(bootflag, 0644, bootflag_get, bootflag_set);
> -static DEVICE_ATTR(boottime, 0644, boottime_get, boottime_set);
> -static DEVICE_ATTR(channel, 0644, channel_get, channel_set);
> -static DEVICE_ATTR(mesh_id, 0644, mesh_id_get, mesh_id_set);
> -static DEVICE_ATTR(protocol_id, 0644, protocol_id_get, protocol_id_set);
> -static DEVICE_ATTR(metric_id, 0644, metric_id_get, metric_id_set);
> -static DEVICE_ATTR(capability, 0644, capability_get, capability_set);
> +static DEVICE_ATTR(bootflag, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, bootflag_get, bootflag_set);
> +static DEVICE_ATTR(boottime, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, boottime_get, boottime_set);
> +static DEVICE_ATTR(channel, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, channel_get, channel_set);
> +static DEVICE_ATTR(mesh_id, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, mesh_id_get, mesh_id_set);
> +static DEVICE_ATTR(protocol_id, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, protocol_id_get, protocol_id_set);
> +static DEVICE_ATTR(metric_id, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, metric_id_get, metric_id_set);
> +static DEVICE_ATTR(capability, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, capability_get, capability_set);
> 
> static struct attribute *boot_opts_attrs[] = {
> 	&dev_attr_bootflag.attr,
> -- 
> 2.9.2
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
