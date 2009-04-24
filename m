From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] vxge: fix possible NULL dereference in vxge-traffic.c
Date: Fri, 24 Apr 2009 01:00:18 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7705313EEF@nekter>
References: <1240536698-10821-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Alexander Beregalov" <a.beregalov@gmail.com>,
	<netdev@vger.kernel.org>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:10473 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbZDXFAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 01:00:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1240536698-10821-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH] vxge: fix possible NULL dereference in vxge-traffic.c
> 
> If vpath is NULL then hldev is NULL also.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>  drivers/net/vxge/vxge-traffic.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-
> traffic.c
> index 7be0ae1..506625b 100644
> --- a/drivers/net/vxge/vxge-traffic.c
> +++ b/drivers/net/vxge/vxge-traffic.c
> @@ -1923,7 +1923,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  	if (vpath == NULL) {
>  		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
>  			alarm_event);
> -		goto out;
> +		goto out2;
>  	}
> 
>  	hldev = vpath->hldev;
> @@ -2161,7 +2161,7 @@ enum vxge_hw_status
__vxge_hw_vpath_alarm_process(
>  	}
>  out:
>  	hldev->stats.sw_dev_err_stats.vpath_alarms++;
> -
> +out2:
>  	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
>  		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
>  		return VXGE_HW_OK;
> --
> 1.6.2.3
Looks good, thanks.

Acked-by: Ram Vepa <ram.vepa@neterion.com>
