From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] use xfrm direction when lookup policy
Date: Tue, 19 Mar 2013 10:35:36 -0400 (EDT)
Message-ID: <20130319.103536.2293402411730251000.davem@davemloft.net>
References: <1363703070-2910-1-git-send-email-baker.zhang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	baker.zhang@gmail.com
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363703070-2910-1-git-send-email-baker.zhang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baker Zhang <baker.kernel@gmail.com>
Date: Tue, 19 Mar 2013 22:24:30 +0800

> because xfrm policy direction has same value with corresponding
> flow direction, so this problem is covered.
> 
> In xfrm_lookup and __xfrm_policy_check, flow_cache_lookup is used to
> accelerate the lookup.
> 
> Flow direction is given to flow_cache_lookup by policy_to_flow_dir.
> 
> When the flow cache is mismatched, callback 'resolver' is called.
> 
> 'resolver' requires xfrm direction,
> so convert direction back to xfrm direction.
> 
> Signed-off-by: Baker Zhang <baker.zhang@gmail.com>

Since this is a cleanup and doesn't really fix a bug, I've applied
this to net-next.

Thanks.
