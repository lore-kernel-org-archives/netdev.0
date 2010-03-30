From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: avoid BUG_ON() with large packets when
 CONFIG_DEBUG_SG=y
Date: Mon, 29 Mar 2010 22:08:59 -0700 (PDT)
Message-ID: <20100329.220859.94049113.davem@davemloft.net>
References: <201003301526.35720.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751498Ab0C3FJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 01:09:00 -0400
In-Reply-To: <201003301526.35720.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Tue, 30 Mar 2010 15:26:35 +1030

> AFAICT only weird kvm setups and lguest traverse this code path now.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Shirley Ma already posted a fix for this, and you missed the
add_recvbuf_small() case in your version.

I'll be applying Shirley's patch to net-next-2.6
