From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH CFT 12/30] net: fec: ensure fec_enet_free_buffers()
	properly cleans the rings
Date: Tue, 1 Jul 2014 15:48:44 +0100
Message-ID: <20140701144843.GW32514@n2100.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk> <E1X0XwQ-0001Na-Kg@rmk-PC.arm.linux.org.uk> <53ADBC8A.8070103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Fugang Duan <B38611@freescale.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:50039 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753916AbaGAOst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 10:48:49 -0400
Content-Disposition: inline
In-Reply-To: <53ADBC8A.8070103@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2014 at 10:48:42PM +0400, Sergei Shtylyov wrote:
>    dev_kfree_skb() (actually, consume_skb() that it calls) already checks 
> 'skb' for NULL.

This patch has now been updated for that, thanks.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
