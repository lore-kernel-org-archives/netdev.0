From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: voidify STP setter and
 FDB/VLAN add ops
Date: Fri, 08 Apr 2016 16:51:00 -0400 (EDT)
Message-ID: <20160408.165100.1546798904754346458.davem@davemloft.net>
References: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com,
	jiri@resnulli.us, sfeldma@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699AbcDHUvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:51:04 -0400
In-Reply-To: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  6 Apr 2016 11:55:02 -0400

> Neither the DSA layer nor the bridge code (see br_set_state) really care
> about eventual errors from STP state setters, so make it void.
> 
> The DSA layer separates the prepare and commit phases of switchdev in
> two different functions. Logical errors must not happen in commit
> routines, so make them void.
> 
> Changes v1 -> v2:
>   - rename port_stp_update to port_stp_state_set
>   - don't change code flow of bcm_sf2_sw_br_set_stp_state
>   - prefer netdev_err over netdev_warn

Series applied.
