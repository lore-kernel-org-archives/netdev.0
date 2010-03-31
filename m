From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: avoid BUG_ON() with large packets when CONFIG_DEBUG_SG=y
Date: Wed, 31 Mar 2010 11:05:18 +1030
Message-ID: <201003311105.19014.rusty@rustcorp.com.au>
References: <201003301526.35720.rusty@rustcorp.com.au> <20100329.220859.94049113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com,
	Shirley Ma <mashirle@us.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55520 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001Ab0CaBYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 21:24:31 -0400
In-Reply-To: <20100329.220859.94049113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 03:38:59 pm David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Tue, 30 Mar 2010 15:26:35 +1030
> 
> > AFAICT only weird kvm setups and lguest traverse this code path now.
> > 
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Shirley Ma already posted a fix for this, and you missed the
> add_recvbuf_small() case in your version.
> 
> I'll be applying Shirley's patch to net-next-2.6

Excellent, thanks.  Shirley, please cc me in future.

Thanks,
Rusty.
