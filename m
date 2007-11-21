From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Routing tables associated with VLANs dissappear when parent
 ethX down/up
Date: Wed, 21 Nov 2007 12:00:27 -0800
Message-ID: <20071121120027.54c277ea@freepuppy.rosehill>
References: <474387E4.7020802@candelatech.com>
	<47448C4F.3060107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52578 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751376AbXKUUBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 15:01:11 -0500
In-Reply-To: <47448C4F.3060107@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Nov 2007 11:51:43 -0800
Ben Greear <greearb@candelatech.com> wrote:

> For consideration, this patch seems to work for me.  I'm not sure
> why we ever listed to these events.  I've only tested on a NIC that
> doesn't support hw-accel at the moment..will test with e1000 later.
> 
> Thanks,
> Ben
> 

But then if you are doing bonding or bridging of vlan's 
and you bring down the root network device, the upper layer is not
notified (for failover).

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
