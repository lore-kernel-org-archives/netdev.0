From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/19] Remove support from bridge bypass
 for mlxsw/rocker drivers
Date: Thu, 08 Jun 2017 14:17:03 -0400 (EDT)
Message-ID: <20170608.141703.1743511775233597085.davem@davemloft.net>
References: <20170608064428.4785-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdFHSRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:17:05 -0400
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  8 Jun 2017 08:44:09 +0200

> Currently setting bridge port attributes and adding FDBs are done via
> setting the SELF flag which implies unconsistent offloading model. This
> patch-set fixes this behavior by making the bridge and drivers which are
> using it to be totally in sync.
> 
> This implies several changes:
> - Offloading bridge flags from the bridge code.
> - Sending notification about FDB add/del to the software bridge in a 
>   similiar way it is done for the hardware externally learned FDBs.
> 
> By making the offloading model more consistent a cleanup is done in
> the drivers supporting it. This is done in order to remove un-needed
> logic related to dump operation which is redundant.
> 
> First add missing functionality to bridge, then clean up the mlxsw/rocker
> drivers.
> ---
> v1->v2
> - Move bridge-switchdev related stuff to br_switchdev.c as suggested by Nik

Series applied.

I really appreciate how you split these changes up to make them easier
to review.

Thanks.
