From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Wed, 21 Nov 2007 10:35:31 -0800 (PST)
Message-ID: <20071121.103531.267691506.davem@davemloft.net>
References: <20071121124532.GA17263@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbXKUSfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 13:35:32 -0500
In-Reply-To: <20071121124532.GA17263@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 21 Nov 2007 07:45:32 -0500

> 
> SO_NO_CHECK support for IPv6 appeared to be missing. This is presented,
> based on a reading of net/ipv4/udp.c.
> 
> I wonder if IPv4's CHECKSUM_PARTIAL check from udp_push_pending_frames()
> also needs to be copied to IPv6?
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

IPV6 specifies that, unlike ipv4, this no-checksum behavior
is not allowed.
