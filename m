From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: move sg off stack
Date: Tue, 6 Apr 2010 12:44:28 +0930
Message-ID: <201004061244.29187.rusty@rustcorp.com.au>
References: <20100331.031636.04083770.davem@davemloft.net> <20100331124156.GA4598@redhat.com> <20100401.192648.185498218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jpirko@redhat.com, xma@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58126 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115Ab0DFDOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 23:14:31 -0400
In-Reply-To: <20100401.192648.185498218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Apr 2010 12:56:48 pm David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 31 Mar 2010 15:41:58 +0300
> 
> > Move sg structure off stack and into virtnet_info structure.
> > This helps remove extra sg_init_table calls as well as reduce
> > stack usage.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> > 
> > Compile-tested only for now.
> > Shirley, Rusty Russell, does this fix CONFIG_DEBUG_SG=y for you?

Yes, this fixes the BUG_ON() for me (trivial changes to base on Linus'
tree only).

Thanks,
Rusty.
