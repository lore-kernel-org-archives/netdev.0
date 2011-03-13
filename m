From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2 PATCH 2/9] xfrm: Add basic infrastructure to support
 IPsec extended sequence numbers
Date: Sat, 12 Mar 2011 22:53:33 -0800 (PST)
Message-ID: <20110312.225333.193705435.davem@davemloft.net>
References: <20110308100407.GB31402@secunet.com>
	<20110308100543.GD31402@secunet.com>
	<20110313064457.GB10849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, abadea@ixiacom.com, agruen@suse.de,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20110313064457.GB10849@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 13 Mar 2011 14:44:57 +0800

> On Tue, Mar 08, 2011 at 11:05:43AM +0100, Steffen Klassert wrote:
>> This patch adds the struct xfrm_replay_state_esn which will be
>> used to support IPsec extended sequence numbers and anti replay windows
>> bigger than 32 packets. Also we add a function that returns the actual
>> size of the xfrm_replay_state_esn, a xfrm netlink atribute and a xfrm state
>> flag for the use of extended sequence numbers.
>> 
>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> All the remaining eight patches look good to me.
> 
> Dave, how would you like to handle this patch-set? As Steffen's
> first crypto patch is completely self-contained, perhaps you could
> just include it along with the rest of the series in your tree?

Sure, I can do that.

Can I add your ACK to all of the patches?
