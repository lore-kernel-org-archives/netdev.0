From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/13] Update DSA's FDB API and perform
 switchdev cleanup
Date: Mon, 07 Aug 2017 14:49:49 -0700 (PDT)
Message-ID: <20170807.144949.1849322815118190718.davem@davemloft.net>
References: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        mlxsw@mellanox.com
To: arkadis@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGVtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:49:51 -0400
In-Reply-To: <1502025351-41261-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>
Date: Sun,  6 Aug 2017 16:15:38 +0300

> The patchset adds support for configuring static FDB entries via the
> switchdev notification chain. The current method for FDB configuration
> uses the switchdev's bridge bypass implementation. In order to support 
> this legacy way and to perform the switchdev cleanup, the implementation
> is moved inside DSA.
> 
> The DSA drivers cannot sync the software bridge with hardware learned
> entries and use the switchdev's implementation of bypass FDB dumping.
> Because they are the only ones using this functionality, the fdb_dump
> implementation is moved from switchdev code into DSA.
> 
> Finally after this changes a major cleanup in switchdev can be done.
> ---
> Please see individual patches for patch specific change logs.
> v1->v2
> - Split MDB/vlan dump removal into core/driver removal.
> 
> v2->v3
> - The self implementation for FDB add/del is moved inside DSA.

Series applied, thank you.
