From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 09:28:15 -0700
Message-ID: <4832FC1F.90208@candelatech.com>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net> <4832F260.5000104@candelatech.com> <20080520162011.GT28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:59895 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755885AbYETQ2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 12:28:20 -0400
In-Reply-To: <20080520162011.GT28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> I would certainly be happy to see NETIF_F_GSO_MASK narrowed.  It's just a
> question of whether the low-order or high-order bits are removed.  My
> instinct is not to change the existing assigned flags if it's not really
> necessary.  They are exposed through /sys/class/net/ even if the flag
> names aren't part of the user-land headers.
>
> Ben.
>   
I guess it doesn't matter so much to me either way..so long as it is 
narrowed one
way or another, and preferably narrowed enough to allow plenty of new flags
down the road.

Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


