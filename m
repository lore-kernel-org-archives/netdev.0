From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Fri, 13 Jun 2008 15:43:07 -0700
Message-ID: <20080613154307.4a6f721f@extreme>
References: <20080613223815.GD11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33037 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755380AbYFMWnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 18:43:13 -0400
In-Reply-To: <20080613223815.GD11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jun 2008 23:38:16 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Selected device feature bits can be propagated to VLAN devices, so we
> can make use of TX checksum offload and TSO on VLAN-tagged packets.
> However, if the physical device does not do VLAN tag insertion or
> generic checksum offload then the test for TX checksum offload in
> dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
> false.

Are you sure that some hardware isn't broken and can do vlan tag
insertion or checksumming but not both?
