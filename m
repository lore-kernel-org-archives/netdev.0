From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NET-NEXT 0/10] hardware time stamping with new fields
 in shinfo
Date: Sun, 15 Feb 2009 23:16:26 -0800 (PST)
Message-ID: <20090215.231626.160752710.davem@davemloft.net>
References: <1234450670.5914.9.camel@ecld0pohly>
	<1234450981.5914.11.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnstul@us.ibm.com, john.ronciak@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752002AbZBPHQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 02:16:43 -0500
In-Reply-To: <1234450981.5914.11.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Thu, 12 Feb 2009 16:03:01 +0100

> This revision of the patch series transports hardware time stamps from
> the hardware into user space via additional fields in struct
> skb_shared_info. It's based on net-next-2.6 as of this morning.
> 
> This is the solution that emerged from the discussion of the other
> approaches suggested before (reuse tstamp, extend skbuff, optional
> structs): it has the advantage of not touching skbuff and also has the
> simplest implementation.
> 
> The clocksource and timecompare patches have been reviewed by John
> Stultz. He doesn't mind merging them via the net subtree.
> 
> John Ronciak reviewed the igb driver patches. He suggested to merge the
> patches as they; after all, PTPd already works fine. I just tested again
> on 32 and 64 bit x86, both with the timestamping example programs as
> well as with PTPd. Latest patched PTPd is here:
>         http://github.com/pohly/ptpd/tree/master
> 
> The open TODOs in the igb driver will be fixed. We think that this will
> be easier with the infrastructure and the driver in a regular kernel
> tree.

Ok, I applied everything and pushed it out to net-next-2.6, let's
see how this goes :-)

That TX clone wrt. skb_orphan() issue will need a happier solution.

Can you describe that problem in detail?  Maybe someone can come
up with a way to avoid that stuff.

Thanks.
