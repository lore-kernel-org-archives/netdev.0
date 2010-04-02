From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: move sg off stack
Date: Thu, 01 Apr 2010 19:26:48 -0700 (PDT)
Message-ID: <20100401.192648.185498218.davem@davemloft.net>
References: <20100331.031636.04083770.davem@davemloft.net>
	<20100331124156.GA4598@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, jpirko@redhat.com, xma@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59592
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756044Ab0DBC0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:26:48 -0400
In-Reply-To: <20100331124156.GA4598@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 31 Mar 2010 15:41:58 +0300

> Move sg structure off stack and into virtnet_info structure.
> This helps remove extra sg_init_table calls as well as reduce
> stack usage.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> Compile-tested only for now.
> Shirley, Rusty Russell, does this fix CONFIG_DEBUG_SG=y for you?

I'll apply this once I see some ACKs on testing.

Thanks.
