From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan packets when
 vid not used.
Date: Mon, 08 Nov 2010 13:26:36 -0800 (PST)
Message-ID: <20101108.132636.246537518.davem@davemloft.net>
References: <1289251381-6671-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754554Ab0KHV0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:26:12 -0500
In-Reply-To: <1289251381-6671-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon,  8 Nov 2010 13:23:01 -0800

> Normally hardware accelerated vlan packets are quickly dropped if
> there is no corresponding vlan device configured.  The one exception
> is promiscuous mode, where we allow all of these packets through so
> they can be picked up by tcpdump.  However, this behavior causes a
> crash if we actually try to receive these packets.  This fixes that
> crash by ignoring packets with vids not corresponding to a configured
> device in the vlan hwaccel routines and then dropping them before they
> get to consumers in the network stack.
> 
> This patch applies only to 2.6.36 stable.  The problem was introduced
> in that release and is already fixed by larger changes to the vlan
> code in 2.6.37.
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Tested-by: Nikola Ciprich <extmaillist@linuxbox.cz>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Acked-by: David S. Miller <davem@davemloft.net>
