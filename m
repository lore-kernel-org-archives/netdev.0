From: David Miller <davem@davemloft.net>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 06 Sep 2010 13:11:53 -0700 (PDT)
Message-ID: <20100906.131153.39173875.davem@davemloft.net>
References: <20100906103505.GA15254@redhat.com>
	<1283787867.2654.600.camel@edumazet-laptop>
	<20100906195330.GA30715@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942Ab0IFULg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:11:36 -0400
In-Reply-To: <20100906195330.GA30715@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 6 Sep 2010 22:53:30 +0300

> On Mon, Sep 06, 2010 at 05:44:27PM +0200, Eric Dumazet wrote:
>> It would be a surprise to use tx mmap (presumably to get high
>> performance), and a modular af_unix ;)
> 
> Hmm, this seems to be what distros ship. If it's illegal, we should disable
> this in Kconfig?

He said it would be illogical to configure the kernel like this if
the goal is top performance, he didn't say it was illegal.
