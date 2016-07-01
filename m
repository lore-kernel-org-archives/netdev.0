From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 10/42] mlxsw: spectrum_router: Add basic ipv4
 router initialization
Date: Fri, 1 Jul 2016 08:39:01 -0600
Message-ID: <15542d5f-e11e-4901-0e36-8231012e8f7e@cumulusnetworks.com>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	tgraf@suug.ch, jhs@mojatatu.com, linville@tuxdriver.com,
	ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:36316 "EHLO
	mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbcGAOi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:38:58 -0400
Received: by mail-it0-f44.google.com with SMTP id a5so19757470ita.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:38:58 -0700 (PDT)
In-Reply-To: <1467381910-3445-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/16 8:04 AM, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
> index 05d5fcc..c2ac037 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
> @@ -74,6 +74,8 @@
>
>  #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
>
> +#define MLXSW_SP_RIF_MAX 800

At most 800 RIFs can be created? Why 800?
