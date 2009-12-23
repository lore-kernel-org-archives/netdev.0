From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: add support for at76c50x-usb driver
Date: Wed, 23 Dec 2009 17:12:15 -0500
Message-ID: <4B3295BF.6030809@garzik.org>
References: <1261578587-3547-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kalle Valo <kalle.valo@iki.fi>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:40809 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157AbZLWWMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 17:12:17 -0500
Received: by yxe17 with SMTP id 17so7177260yxe.33
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 14:12:17 -0800 (PST)
In-Reply-To: <1261578587-3547-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2009 09:29 AM, John W. Linville wrote:
> Signed-off-by: John W. Linville<linville@tuxdriver.com>
> ---
>   Makefile.am    |    2 +-
>   at76c50x-usb.c |   32 ++++++++++++++++++++++++++++++++
>   ethtool-util.h |    2 ++
>   ethtool.c      |    1 +
>   4 files changed, 36 insertions(+), 1 deletions(-)
>   create mode 100644 at76c50x-usb.c

> +at76c50x_usb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> +{
> +	u8 version = (u8)(regs->version>>  24);
> +	u8 rev_id = (u8)(regs->version);
> +	char *ver_string;
> +
> +	if (version != 0)
> +		return -1;
> +
> +	ver_string = hw_versions[rev_id];
> +	fprintf(stdout,
> +		"Hardware Version                    %s\n",
> +		ver_string);
> +
> +	return 0;

applied...  don't forget to update 'version', should the register dump 
data passed to userspace ever change.

