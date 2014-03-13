From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: Schedule NAPI from dealloc
 thread instead of callback
Date: Thu, 13 Mar 2014 15:48:58 -0400 (EDT)
Message-ID: <20140313.154858.1537389952540665300.davem@davemloft.net>
References: <20140313101720.GA16807@zion.uk.xensource.com>
	<1394707350.25873.34.camel@kazak.uk.xensource.com>
	<5321D265.8070907@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5321D265.8070907@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 13 Mar 2014 15:44:37 +0000

> I've just discussed this with Ian, this solution still doesn't solve
> the racing between NAPI and the dealloc thread, however it only causes
> some unnecessary napi_schedule's, not ring stalls.
> There is a better solution, I'll post it as soon as it passes all the
> test!

Ok, I'm skipping this patch therefore.
