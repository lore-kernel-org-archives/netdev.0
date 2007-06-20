From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.22-rc4-git6] forcedeth: use unicast receive mode for
 WoL
Date: Wed, 20 Jun 2007 19:15:26 -0400
Message-ID: <4679B50E.7080605@garzik.org>
References: <20070614131638.1a5cef4c@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Tim Mann <mann@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45622 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbXFTXP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:15:28 -0400
In-Reply-To: <20070614131638.1a5cef4c@mann-lx.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Mann wrote:
> I happened to notice that a system with an NVidia NIC using the
> forcedeth driver won't wake-on-LAN if the interface was in promiscuous
> mode when you power off.  By experiment, it looks like
> the hardware needs to have NvRegPacketFilterFlags set to
> NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR (i.e., receive unicast packets to my
> address) in order for WoL to work.
> 
> Jeff Garzik writes: "NVIDIA says the patch looks OK."  I didn't venture
> to insert a signed-off-by line with his name on it, though.
> 
> Signed-off-by: Tim Mann <mann@vmware.com>

applied to #upstream-fixes (2.6.22)


