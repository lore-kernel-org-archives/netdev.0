From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 1/3] mlxsw: spectrum: Do not assume PAUSE frames are
 disabled
Date: Mon, 8 Aug 2016 18:28:52 +0200
Message-ID: <20160808162852.GL1944@nanopsycho.orion>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
 <1470321382-10426-2-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36449 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbcHHQ2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:28:55 -0400
Received: by mail-wm0-f68.google.com with SMTP id x83so16457342wma.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:28:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470321382-10426-2-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 04, 2016 at 04:36:20PM CEST, idosch@mellanox.com wrote:
>When ieee_setpfc() gets called, PAUSE frames are not necessarily
>disabled on the port.
>
>Check if PAUSE frames are disabled or enabled and configure the port's
>headroom buffer accordingly.
>
>Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
