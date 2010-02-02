From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] virtio: Add ability to detach unused buffers from
 vrings
Date: Tue, 02 Feb 2010 15:59:11 -0800 (PST)
Message-ID: <20100202.155911.152356006.davem@davemloft.net>
References: <201001292346.43675.rusty@rustcorp.com.au>
	<201001292349.05360.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mashirle@us.ibm.com, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755828Ab0BBX66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 18:58:58 -0500
In-Reply-To: <201001292349.05360.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 29 Jan 2010 23:49:05 +1030

> From: Shirley Ma <mashirle@us.ibm.com>
> 
> There's currently no way for a virtio driver to ask for unused
> buffers, so it has to keep a list itself to reclaim them at shutdown.
> This is redundant, since virtio_ring stores that information.  So
> add a new hook to do this.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> Signed-off-by: Amit Shah <amit.shah@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
