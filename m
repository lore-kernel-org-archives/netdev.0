From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [1/8,RFC] CAIF Protocol Stack
Date: Mon, 05 Oct 2009 14:55:48 +0200
Message-ID: <4AC9ECD4.70602@babic.homelinux.org>
References: <1253727026-10233-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout24.attiva.biz ([85.37.16.25]:11429 "EHLO
	smtpout24.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535AbZJENB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 09:01:58 -0400
In-Reply-To: <1253727026-10233-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:

> diff --git a/include/linux/caif/caif_ioctl.h b/include/linux/caif/caif_ioctl.h
> new file mode 100644
> index 0000000..4fdd648
> --- /dev/null
> +++ b/include/linux/caif/caif_ioctl.h

[snip]

> +/**
> + * union caif_action
> + * This union is used to configure a new CAIF Channel and
> + */
> +
> +union caif_action {
> +	struct caif_device_name delete_channel;
> +	struct caif_channel_create_action create_channel;
> +};

It seems this structure is defined twice (here and in caif_actions.h)
and some modules (at least phyif_ser, I could check) are not compiled
clean, because both header files are included. Maybe should be protected
with ifndef __KERNEL__ ?

Regards,
Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
