From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/17] net: dsa: mv88e6xxx: rework ATU
 support
Date: Sun, 12 Mar 2017 23:54:21 -0700 (PDT)
Message-ID: <20170312.235421.213788051759862527.davem@davemloft.net>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdCMGyX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:54:23 -0400
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat, 11 Mar 2017 16:12:46 -0500

> The purpose of this patch series is to rework the code related to the
> Address Translation Unit (ATU), and bring support for it to the 88E6390
> family of switch chips.
> 
> All Global (1) ATU related code have been reworked and moved to its own
> file. Some port related bits used for ATU configuration (such as the
> Learn2All and MessagePort feature) have also been taken care of.
> 
> The ports' mode and egress flooding mode have been refactored to fix the
> egress of frames with unknown unicast or multicast destination address,
> and write all these bits regardless the port mode (Normal, DSA, etc.)
> 
> Finally remove the eth_addr_greater which was only used by mv88e6xxx.
> 
> Changes in v2:
>   - add Reviewed-by tags
>   - split mv88e6xxx_g1_atu_set_age_time and mv88e6xxx_atu_setup addition
>   - remove DSA_TAG_PROTO_TRAILER check
>   - split Message Port and Learn2All addition
>   - remove unused MV88E6XXX_FLAG_G1_ATU_FID flag
>   - add dsa_is_normal_port helper

Series applied.
