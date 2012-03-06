From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vlan: Support sending custom Ethernet CRC.
Date: Tue, 6 Mar 2012 16:16:34 +0000
Message-ID: <1331050594.2333.5.camel@bwh-desktop>
References: <1330999558-14270-1-git-send-email-greearb@candelatech.com>
	 <20120305.211449.2159840360912052625.davem@davemloft.net>
	 <4F558BBD.1050400@candelatech.com>
	 <20120305.231213.1657967586545663587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <greearb@candelatech.com>, <netdev@vger.kernel.org>,
	<kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:44461 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754430Ab2CFQQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 11:16:37 -0500
In-Reply-To: <20120305.231213.1657967586545663587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-05 at 23:12 -0500, David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Mon, 05 Mar 2012 19:59:57 -0800
> 
> > On 03/05/2012 06:14 PM, David Miller wrote:
> >> From: greearb@candelatech.com
> >> Date: Mon,  5 Mar 2012 18:05:58 -0800
> >>
> >>> NOTE:  You will probably have to disable any
> >>> VLAN hardware assist on the underlying device to get
> >>> this to properly send packets with this feature enabled.
> >>
> >> This need to be therefore handled specifically on a device-by-device
> >> basis, and VLAN custom CRC disabled unless the device explicitly
> >> states that it can handle this situation properly and has any
> >> necessary feature rule enforcement codified.
> > 
> > I'll see what I can come up with.  Maybe figure out how to propagate
> > a flag up from the NIC when it is in a state that can handle VLAN +
> > custom-CRC
> > and only enable the flag on the VLAN in that case...
> 
> NETIF_F_CAN_VLAN_WITH_CUSTOM_CRC

Er... vlan_features?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
