From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/8] Add support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 17:29:41 -0700 (PDT)
Message-ID: <20170328.172941.239828400657762047.davem@davemloft.net>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932352AbdC2A3q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 20:29:46 -0400
In-Reply-To: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 28 Mar 2017 17:24:09 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Arkadi says:
> 
> While doing the hardware offloading process much of the hardware
> specifics cannot be presented. An example for such is the routing
> LPM algorithm which differ in hardware implementation from the
> kernel software implementation. The only information the user receives
> is whether specific route is offloaded or not, but he cannot really
> understand the underlying implementation nor get the specific statistics
> related to that process.
> 
> Another example is ACL offload using TC which is commonly implemented
> using TCAM memory. Currently there is no capability to gain visibility
> into the TCAM structure and to debug suboptimal resource allocation.
> 
> This patchset introduces capability for exporting the ASICs pipeline
> abstraction via devlink infrastructure, which should serve as an
> complementary tool. This infrastructure allows the user to get visibility
> into the ASIC by modeling it as a set of match/action tables.
 ...

Series applied, thanks!
