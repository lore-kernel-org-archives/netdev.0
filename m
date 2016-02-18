From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: do not use fdb in metadata mode
Date: Thu, 18 Feb 2016 15:01:39 -0500 (EST)
Message-ID: <20160218.150139.2130647760401961289.davem@davemloft.net>
References: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946345AbcBRUBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:01:40 -0500
In-Reply-To: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 16 Feb 2016 22:18:26 +0100

> In metadata mode, the vxlan interface is not supposed to use the fdb control
> plane but an external one (openvswitch or static routes). With the current
> code, packets may leak into the fdb handling code which usually causes them
> to be dropped anyway but may have strange side effects.
> 
> Just drop the packets directly when in metadata mode if the destination data
> are not correctly provided on egress.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks.
