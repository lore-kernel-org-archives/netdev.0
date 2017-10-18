From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH v2 02/15] usb: gadget: make config_item_type structures const
Date: Wed, 18 Oct 2017 19:05:11 +0300
Message-ID: <1985905.z83BJQzMUS@avalon>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1508167134-6243-3-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: julia.lawall-L2FTfq7BK8M@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org,
        kishon-l0cyMroinI0@public.gmane.org, bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org,
        ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org,
        linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ocfs2-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
To: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508167134-6243-3-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bhumika,

Thank you for the patch.

On Monday, 16 October 2017 18:18:41 EEST Bhumika Goyal wrote:
> Make these structures const as they are only passed to the const
> argument of the functions config_{group/item}_init_type_name.
> 
> Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> * Changes in v2- Combine all the followup patches and the constification
> patches into a series.
> 
>  drivers/usb/gadget/function/f_acm.c          |  2 +-
>  drivers/usb/gadget/function/f_ecm.c          |  2 +-
>  drivers/usb/gadget/function/f_eem.c          |  2 +-
>  drivers/usb/gadget/function/f_fs.c           |  2 +-
>  drivers/usb/gadget/function/f_hid.c          |  2 +-
>  drivers/usb/gadget/function/f_loopback.c     |  2 +-
>  drivers/usb/gadget/function/f_mass_storage.c |  4 +--
>  drivers/usb/gadget/function/f_midi.c         |  2 +-
>  drivers/usb/gadget/function/f_ncm.c          |  2 +-
>  drivers/usb/gadget/function/f_obex.c         |  2 +-
>  drivers/usb/gadget/function/f_phonet.c       |  2 +-
>  drivers/usb/gadget/function/f_printer.c      |  2 +-
>  drivers/usb/gadget/function/f_rndis.c        |  2 +-
>  drivers/usb/gadget/function/f_serial.c       |  2 +-
>  drivers/usb/gadget/function/f_sourcesink.c   |  2 +-
>  drivers/usb/gadget/function/f_subset.c       |  2 +-
>  drivers/usb/gadget/function/f_tcm.c          |  2 +-
>  drivers/usb/gadget/function/f_uac1.c         |  2 +-
>  drivers/usb/gadget/function/f_uac1_legacy.c  |  2 +-
>  drivers/usb/gadget/function/f_uac2.c         |  2 +-
>  drivers/usb/gadget/function/uvc_configfs.c   | 50 ++++++++++++------------
>  21 files changed, 46 insertions(+), 46 deletions(-)

[snip]

> diff --git a/drivers/usb/gadget/function/uvc_configfs.c
> b/drivers/usb/gadget/function/uvc_configfs.c index 844cb73..f76619f 100644
> --- a/drivers/usb/gadget/function/uvc_configfs.c
> +++ b/drivers/usb/gadget/function/uvc_configfs.c
> @@ -127,7 +127,7 @@ static struct uvcg_control_header
> *to_uvcg_control_header(struct config_item *it NULL,
>  };
> 
> -static struct config_item_type uvcg_control_header_type = {
> +static const struct config_item_type uvcg_control_header_type = {
>  	.ct_attrs	= uvcg_control_header_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -170,7 +170,7 @@ static void uvcg_control_header_drop(struct config_group
> *group, .drop_item		= uvcg_control_header_drop,
>  };
> 
> -static struct config_item_type uvcg_control_header_grp_type = {
> +static const struct config_item_type uvcg_control_header_grp_type = {
>  	.ct_group_ops	= &uvcg_control_header_grp_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -265,7 +265,7 @@ static ssize_t uvcg_default_processing_bm_controls_show(
> NULL,
>  };
> 
> -static struct config_item_type uvcg_default_processing_type = {
> +static const struct config_item_type uvcg_default_processing_type = {
>  	.ct_attrs	= uvcg_default_processing_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -277,7 +277,7 @@ static ssize_t uvcg_default_processing_bm_controls_show(
> struct config_group	group;
>  } uvcg_processing_grp;
> 
> -static struct config_item_type uvcg_processing_grp_type = {
> +static const struct config_item_type uvcg_processing_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -382,7 +382,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
>  	NULL,
>  };
> 
> -static struct config_item_type uvcg_default_camera_type = {
> +static const struct config_item_type uvcg_default_camera_type = {
>  	.ct_attrs	= uvcg_default_camera_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -394,7 +394,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
>  	struct config_group	group;
>  } uvcg_camera_grp;
> 
> -static struct config_item_type uvcg_camera_grp_type = {
> +static const struct config_item_type uvcg_camera_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -460,7 +460,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
>  	NULL,
>  };
> 
> -static struct config_item_type uvcg_default_output_type = {
> +static const struct config_item_type uvcg_default_output_type = {
>  	.ct_attrs	= uvcg_default_output_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -472,7 +472,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
>  	struct config_group	group;
>  } uvcg_output_grp;
> 
> -static struct config_item_type uvcg_output_grp_type = {
> +static const struct config_item_type uvcg_output_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -481,7 +481,7 @@ static ssize_t uvcg_default_camera_bm_controls_show(
>  	struct config_group	group;
>  } uvcg_terminal_grp;
> 
> -static struct config_item_type uvcg_terminal_grp_type = {
> +static const struct config_item_type uvcg_terminal_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -586,7 +586,7 @@ static void uvcg_control_class_drop_link(struct
> config_item *src, .drop_link	= uvcg_control_class_drop_link,
>  };
> 
> -static struct config_item_type uvcg_control_class_type = {
> +static const struct config_item_type uvcg_control_class_type = {
>  	.ct_item_ops	= &uvcg_control_class_item_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -596,7 +596,7 @@ static void uvcg_control_class_drop_link(struct
> config_item *src, struct config_group	group;
>  } uvcg_control_class_grp;
> 
> -static struct config_item_type uvcg_control_class_grp_type = {
> +static const struct config_item_type uvcg_control_class_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -605,7 +605,7 @@ static void uvcg_control_class_drop_link(struct
> config_item *src, struct config_group	group;
>  } uvcg_control_grp;
> 
> -static struct config_item_type uvcg_control_grp_type = {
> +static const struct config_item_type uvcg_control_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -857,7 +857,7 @@ static void uvcg_streaming_header_drop_link(struct
> config_item *src, NULL,
>  };
> 
> -static struct config_item_type uvcg_streaming_header_type = {
> +static const struct config_item_type uvcg_streaming_header_type = {
>  	.ct_item_ops	= &uvcg_streaming_header_item_ops,
>  	.ct_attrs	= uvcg_streaming_header_attrs,
>  	.ct_owner	= THIS_MODULE,
> @@ -901,7 +901,7 @@ static void uvcg_streaming_header_drop(struct
> config_group *group, .drop_item		= uvcg_streaming_header_drop,
>  };
> 
> -static struct config_item_type uvcg_streaming_header_grp_type = {
> +static const struct config_item_type uvcg_streaming_header_grp_type = {
>  	.ct_group_ops	= &uvcg_streaming_header_grp_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -1150,7 +1150,7 @@ static ssize_t
> uvcg_frame_dw_frame_interval_store(struct config_item *item, NULL,
>  };
> 
> -static struct config_item_type uvcg_frame_type = {
> +static const struct config_item_type uvcg_frame_type = {
>  	.ct_attrs	= uvcg_frame_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -1419,7 +1419,7 @@ static ssize_t
> uvcg_uncompressed_guid_format_store(struct config_item *item, NULL,
>  };
> 
> -static struct config_item_type uvcg_uncompressed_type = {
> +static const struct config_item_type uvcg_uncompressed_type = {
>  	.ct_group_ops	= &uvcg_uncompressed_group_ops,
>  	.ct_attrs	= uvcg_uncompressed_attrs,
>  	.ct_owner	= THIS_MODULE,
> @@ -1469,7 +1469,7 @@ static void uvcg_uncompressed_drop(struct config_group
> *group, .drop_item		= uvcg_uncompressed_drop,
>  };
> 
> -static struct config_item_type uvcg_uncompressed_grp_type = {
> +static const struct config_item_type uvcg_uncompressed_grp_type = {
>  	.ct_group_ops	= &uvcg_uncompressed_grp_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -1619,7 +1619,7 @@ static struct uvcg_mjpeg *to_uvcg_mjpeg(struct
> config_item *item) NULL,
>  };
> 
> -static struct config_item_type uvcg_mjpeg_type = {
> +static const struct config_item_type uvcg_mjpeg_type = {
>  	.ct_group_ops	= &uvcg_mjpeg_group_ops,
>  	.ct_attrs	= uvcg_mjpeg_attrs,
>  	.ct_owner	= THIS_MODULE,
> @@ -1663,7 +1663,7 @@ static void uvcg_mjpeg_drop(struct config_group
> *group, .drop_item		= uvcg_mjpeg_drop,
>  };
> 
> -static struct config_item_type uvcg_mjpeg_grp_type = {
> +static const struct config_item_type uvcg_mjpeg_grp_type = {
>  	.ct_group_ops	= &uvcg_mjpeg_grp_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -1728,7 +1728,7 @@ static void uvcg_mjpeg_drop(struct config_group
> *group, NULL,
>  };
> 
> -static struct config_item_type uvcg_default_color_matching_type = {
> +static const struct config_item_type uvcg_default_color_matching_type = {
>  	.ct_attrs	= uvcg_default_color_matching_attrs,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -1740,7 +1740,7 @@ static void uvcg_mjpeg_drop(struct config_group
> *group, struct config_group	group;
>  } uvcg_color_matching_grp;
> 
> -static struct config_item_type uvcg_color_matching_grp_type = {
> +static const struct config_item_type uvcg_color_matching_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -2085,7 +2085,7 @@ static void uvcg_streaming_class_drop_link(struct
> config_item *src, .drop_link	= uvcg_streaming_class_drop_link,
>  };
> 
> -static struct config_item_type uvcg_streaming_class_type = {
> +static const struct config_item_type uvcg_streaming_class_type = {
>  	.ct_item_ops	= &uvcg_streaming_class_item_ops,
>  	.ct_owner	= THIS_MODULE,
>  };
> @@ -2095,7 +2095,7 @@ static void uvcg_streaming_class_drop_link(struct
> config_item *src, struct config_group	group;
>  } uvcg_streaming_class_grp;
> 
> -static struct config_item_type uvcg_streaming_class_grp_type = {
> +static const struct config_item_type uvcg_streaming_class_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };
> 
> @@ -2104,7 +2104,7 @@ static void uvcg_streaming_class_drop_link(struct
> config_item *src, struct config_group	group;
>  } uvcg_streaming_grp;
> 
> -static struct config_item_type uvcg_streaming_grp_type = {
> +static const struct config_item_type uvcg_streaming_grp_type = {
>  	.ct_owner = THIS_MODULE,
>  };

Now we have 9 const instances of the config_item_type structure that are 
identical, with only the .ct_owner field set. Should they be all merged into a 
single structure ?

> @@ -2190,7 +2190,7 @@ static void uvc_attr_release(struct config_item *item)
> NULL,
>  };
> 
> -static struct config_item_type uvc_func_type = {
> +static const struct config_item_type uvc_func_type = {
>  	.ct_item_ops	= &uvc_item_ops,
>  	.ct_attrs	= uvc_attrs,
>  	.ct_owner	= THIS_MODULE,


-- 
Regards,

Laurent Pinchart

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
