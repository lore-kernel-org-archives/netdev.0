From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid entry point
Date: Mon, 11 Feb 2008 11:12:59 -0500
Message-ID: <47B0740B.5040006@garzik.org>
References: <Pine.GSO.4.10.10802061527330.18812-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52113 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbYBKQND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:13:03 -0500
In-Reply-To: <Pine.GSO.4.10.10802061527330.18812-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Added s2io_vlan_rx_kill_vid entry point function for unregistering vlan.
> - Fix to aggregate vlan packets. IP offset is incremented by
>   4 bytes if the packet contains vlan header.
> - resubmit for 2.6.24 kernel
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

it's difficult to sort through these patches, because they clash a bit 
with the kernel development model.

You always need to send against the latest kernel (generally davem's 
tree if it's during -rc bug fix cycle, or linus's otherwise).

Once the changes are in place, then email the commit ids or backported 
patches to stable@kernel.org for inclusion in an already-released kernel.

In this case, 2.6.24 was well on its way to being released weeks ago, 
when this set of patches was last resend (and then I subsequently 
screwed up, and apparently applied a wrong patch, as discussed)

So what we need are patches against the latest kernel 
(torvalds/linux-2.6.git), and after those are applied, email 
stable@kernel.org with whatever you want in 2.6.24.x.

	Jeff



