From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/5] mlxsw: small driver update
Date: Fri, 8 Apr 2016 17:51:55 +0200
Message-ID: <20160408155155.GC1932@nanopsycho.orion>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34918 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbcDHPv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:51:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id a140so5324933wma.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:51:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 08, 2016 at 05:45:20PM CEST, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>Cosmetics, in preparation to sharedbuffer patchset.

Dave, I just realized there is dependency on:
"devlink: remove implicit type set in port register" which I sent couple
of minutes after this patchset. I can either resend in bulk, or if you
could apply in order, that would be great.

Thanks and sorry, owe you another beer :)


>
>Jiri Pirko (5):
>  mlxsw: Move devlink port registration into common core code
>  mlxsw: Pass mlxsw_core as a param of mlxsw_core_skb_transmit*
>  mlxsw: Do not pass around driver_priv directly
>  mlxsw: reg: Share direction enum between SBPR, SBCM, SBPM
>  mlxsw: reg: Fix SBPM register name
>
> drivers/net/ethernet/mellanox/mlxsw/core.c         | 56 ++++++++++++++--------
> drivers/net/ethernet/mellanox/mlxsw/core.h         | 26 +++++++---
> drivers/net/ethernet/mellanox/mlxsw/reg.h          | 27 ++++-------
> drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 52 +++++++++-----------
> drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +-
> .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 20 ++++----
> drivers/net/ethernet/mellanox/mlxsw/switchx2.c     | 42 +++++++---------
> 7 files changed, 114 insertions(+), 112 deletions(-)
>
>-- 
>2.5.5
>
