From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [SKY2]: Fix VLAN unregistration
Date: Tue, 29 May 2007 10:16:28 -0700
Message-ID: <20070529101628.7538f770@freepuppy>
References: <4659D174.70301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:39586 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761604AbXE2RYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 13:24:18 -0400
In-Reply-To: <4659D174.70301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 May 2007 20:44:04 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Fix sky2 disabling VLAN completely when the first vid is unregistered.
> 
> For some reason the VLAN code insists on the driver providing a
> vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
> NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
> function. This seems to be a bug though, vlan_rx_add_vid is only
> required with NETIF_F_HW_VLAN_FILTER. Ben?
> 

I put it in the next sky2 patch set. Still waiting for Jeff
to take the last one.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
