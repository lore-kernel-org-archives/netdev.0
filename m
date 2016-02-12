From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/8] Local Checksum Offload
Date: Fri, 12 Feb 2016 05:53:12 -0500 (EST)
Message-ID: <20160212.055312.319096573102657816.davem@davemloft.net>
References: <alpine.LFD.2.20.1602112024140.14893@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	tom@herbertland.net
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbcBLKxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 05:53:16 -0500
In-Reply-To: <alpine.LFD.2.20.1602112024140.14893@ec-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 11 Feb 2016 20:46:00 +0000

> Re-tested VxLAN; everything else is unchanged from v4.
> 
> Changes from v4:
>  * Rebased series to fix conflicts with vxlan/vxlan6 merge.
> 
> Changes from v3:
>  * Fixed inverted checksum values introduced in v3.
>  * Don't mangle zero checksums in GRE.
>  * Clear skb->encapsulation in iptunnel_handle_offloads when not using
>    CHECKSUM_PARTIAL, lest drivers incorrectly interpret that as a request
>    for inner checksum offload.
> 
> Changes from v2:
>  * Added support for IPv4 GRE.
>  * Split out 'always set up for checksum offload' into its own patch.
>  * Removed csum_help from iptunnel_handle_offloads.
>  * Rewrote LCO callers to only fold once.
>  * Simplified nocheck handling.
> 
> Changes from v1:
>  * Enabled support in more encapsulation protocols.
>    I think it now covers everything except GRE.
>  * Wrote up some documentation covering TX checksum offload, LCO and RCO.

Series applied, thanks Edward.
