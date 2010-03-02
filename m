From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 02 Mar 2010 06:06:06 -0800 (PST)
Message-ID: <20100302.060606.73203093.davem@davemloft.net>
References: <1267535426.21749.24.camel@bigi>
	<20100302134656.GC20508@secunet.com>
	<1267538070.21749.27.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	kaber@trash.net, yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753367Ab0CBOFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 09:05:48 -0500
In-Reply-To: <1267538070.21749.27.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 02 Mar 2010 08:54:30 -0500

> On Tue, 2010-03-02 at 14:46 +0100, Steffen Klassert wrote:
> 
>> The problem was spotted by 
>> commit a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
>> xfrm: select sane defaults for xfrm[4|6] gc_thresh
>> 
>> Before this commit, the xfrm garbage collector started to remove
>> stale bundle entries as soon as we reached an amount of 1024
>> bundle entries. Now the default value for the gc_thresh is
>> based on the main route table hash size, so we can have much more
>> bundle entries.
> 
> yikes. Ok. Seems this fix needs to go -stable as well then.

Jamal please do some testing then I'll push Herbert's fix around.
