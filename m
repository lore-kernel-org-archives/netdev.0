From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [bisected regression] Partial breakage of forcedeth driver
Date: Mon, 25 Jul 2011 16:36:24 +0200
Message-ID: <20110725143623.GC2395@minipsycho.brq.redhat.com>
References: <4E2CA683.4010005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: walt <w41ter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab1GYOg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2011 10:36:27 -0400
Content-Disposition: inline
In-Reply-To: <4E2CA683.4010005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 25, 2011 at 01:10:59AM CEST, w41ter@gmail.com wrote:
>Hi gang.
>
>commit 3326c784c9f492e988617d93f647ae0cfd4c8d09
>Author: Jiri Pirko <jpirko@>
>Date:   Wed Jul 20 04:54:38 2011 +0000
>
>    forcedeth: do vlan cleanup
>    
>    - unify vlan and nonvlan rx path
>    - kill np->vlangrp and nv_vlan_rx_register
>    - allow to turn on/off rx vlan accel via ethtool (set_features)
>    
>    Signed-off-by: Jiri Pirko <jpirko@>
>    Signed-off-by: David S. Miller <davem@>
>
>This commit causes networking trouble for my nForce-based motherboard.
>(Details happily supplied if needed.)
>
>I say 'partial' breakage because networking is not completely dead,
>just limping very slowly :)
>
>The simplest test is to ping any host (in my LAN or on the internet,
>makes no difference).  The replies to my ping come at very irregular
>intervals, ranging from normal to 5-10 seconds or so, seemingly at
>random AFAICT.
>
>I'm happy to try any patches, tests, whatever, to help fix this.
>
>Many thanks!


Same is happening on machine I borrowed. ccing list.
Will look at it very soon (no time today).

jirka
