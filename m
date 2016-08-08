From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net 3/3] mlxsw: spectrum: Add missing DCB rollback in
 error path
Date: Mon, 8 Aug 2016 18:30:16 +0200
Message-ID: <20160808163016.GN1944@nanopsycho.orion>
References: <1470321382-10426-1-git-send-email-idosch@mellanox.com>
 <1470321382-10426-4-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33206 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbcHHQaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 12:30:19 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so16511089wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 09:30:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470321382-10426-4-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 04, 2016 at 04:36:22PM CEST, idosch@mellanox.com wrote:
>We correctly execute mlxsw_sp_port_dcb_fini() when port is removed, but
>I missed its rollback in the error path of port creation, so add it.
>
>Fixes: f00817df2b42 ("mlxsw: spectrum: Introduce support for Data Center Bridging (DCB)")
>Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
