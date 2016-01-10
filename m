From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 7/8] mlxsw: Adding layer 2 multicast support
Date: Sun, 10 Jan 2016 21:11:40 +0100
Message-ID: <5692BAFC.9080505@cumulusnetworks.com>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
 <1452456389-2833-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34525 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757185AbcAJULn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 15:11:43 -0500
Received: by mail-wm0-f49.google.com with SMTP id u188so192342773wmu.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 12:11:43 -0800 (PST)
In-Reply-To: <1452456389-2833-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2016 09:06 PM, Jiri Pirko wrote:
> From: Elad Raz <eladr@mellanox.com>
> 
> Add SWITCHDEV_OBJ_ID_PORT_MDB switchdev ops support. On first MDB insertion
> creates a new multicast group (MID) and add members port to the MID. Also
> add new MDB entry for the flooding-domain (fid-vid) and link the MDB entry
> to the newly constructed MC group.
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> - changed GFP_ATOMIC to GFP_KERNEL in __mlxsw_sp_mc_alloc as suggested by Nik
> ---
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   1 +
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  13 ++
>  .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 176 +++++++++++++++++++++
>  3 files changed, 190 insertions(+)
> 

Thanks!

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
