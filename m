From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 03/17] batman-adv: Add network_coding and mcast sysfs
 files to README
Date: Sat, 29 Oct 2016 12:33:01 +0200
Message-ID: <20161029103301.GD1692@nanopsycho.orion>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
 <20161027190150.7880-4-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>
To: Simon Wunderlich <sw@simonwunderlich.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36551 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755665AbcJ2KdG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 06:33:06 -0400
Received: by mail-wm0-f65.google.com with SMTP id c17so10838388wmc.3
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2016 03:33:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161027190150.7880-4-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 27, 2016 at 09:01:36PM CEST, sw@simonwunderlich.de wrote:
>From: Sven Eckelmann <sven@narfation.org>
>
>Signed-off-by: Sven Eckelmann <sven@narfation.org>
>Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
>---
> Documentation/networking/batman-adv.txt | 9 +++++----
> 1 file changed, 5 insertions(+), 4 deletions(-)
>
>diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
>index d414e60..8afa991 100644
>--- a/Documentation/networking/batman-adv.txt
>+++ b/Documentation/networking/batman-adv.txt
>@@ -71,10 +71,11 @@ All  mesh  wide  settings  can be found in batman's own interface
> folder:
> 
> # ls /sys/class/net/bat0/mesh/
>-#aggregated_ogms        distributed_arp_table  gw_sel_class    orig_interval
>-#ap_isolation           fragmentation          hop_penalty     routing_algo
>-#bonding                gw_bandwidth           isolation_mark  vlan0
>-#bridge_loop_avoidance  gw_mode                log_level
>+# aggregated_ogms        fragmentation  isolation_mark  routing_algo
>+# ap_isolation           gw_bandwidth   log_level       vlan0
>+# bonding                gw_mode        multicast_mode
>+# bridge_loop_avoidance  gw_sel_class   network_coding
>+# distributed_arp_table  hop_penalty    orig_interval

I strongly believe it is a huge mistake to use sysfs for things like
this. This should be done via generic netlink api.
>
