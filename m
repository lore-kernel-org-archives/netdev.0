From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Wed, 18 Mar 2009 18:40:14 -0700 (PDT)
Message-ID: <20090318.184014.04350681.davem@davemloft.net>
References: <200903141053.51819.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	stable@kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758107AbZCSBk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 21:40:28 -0400
In-Reply-To: <200903141053.51819.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 14 Mar 2009 10:53:51 +1030

> Impact: Make NetworkManager work with virtio_net
> 
> For now the semantics are simple: There is always carrier.
> 
> This allows a seamless experience with e.g., qemu/kvm
> where NetworkManager just configures and sets up
> everything automagically.
> 
> If/when a generally agreed-upon way to control
> carrier on/off in the emulator/hypervisor level
> emerges, it will be trivial to extend the driver
> to support that too, but for now even this 2-liner
> makes user experience that much better.
> 
> Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks Rusty.
