From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Sat, 14 Jun 2008 00:11:41 +0100
Message-ID: <20080613231139.GE11300@solarflare.com>
References: <20080613223815.GD11300@solarflare.com> <20080613154307.4a6f721f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:40057 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755041AbYFMXLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 19:11:48 -0400
Content-Disposition: inline
In-Reply-To: <20080613154307.4a6f721f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 13 Jun 2008 23:38:16 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > Selected device feature bits can be propagated to VLAN devices, so we
> > can make use of TX checksum offload and TSO on VLAN-tagged packets.
> > However, if the physical device does not do VLAN tag insertion or
> > generic checksum offload then the test for TX checksum offload in
> > dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
> > false.
> 
> Are you sure that some hardware isn't broken and can do vlan tag
> insertion or checksumming but not both?

The second test uses dev->features & dev->vlan_features, so this should
be handled correctly, unless I'm missing some subtlety.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
