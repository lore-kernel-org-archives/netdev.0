From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] mellanox: mlxsw: Use '%zx' to print size_t
 format
Date: Mon, 10 Aug 2015 15:01:15 +0200
Message-ID: <20150810130115.GD2043@nanopsycho>
References: <1439211268-8785-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jiri@mellanox.com, netdev@vger.kernel.org,
	idosch@mellanox.com, eladr@mellanox.com
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35496 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbbHJNBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 09:01:18 -0400
Received: by wicne3 with SMTP id ne3so21187929wic.0
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 06:01:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439211268-8785-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 10, 2015 at 02:54:28PM CEST, fabio.estevam@freescale.com wrote:
>Use '%zx' to print size_t format in order to fix the following build warning:
>
>drivers/net/ethernet/mellanox/mlxsw/item.h:65:3: warning: format '%lx' expects argument of type 'long unsigned int', but argument 6 has type 'size_t' [-Wformat=]
>
>Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
