From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 14:51:42 -0500 (EST)
Message-ID: <20150119.145142.2097530322452295351.davem@davemloft.net>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	stable@vger.kernel.org, fgont@si6networks.com
To: hagen@jauu.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421357665-2804-1-git-send-email-hagen@jauu.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Thu, 15 Jan 2015 22:34:25 +0100

> Reduce the attack vector and stop generating IPv6 Fragment Header for
> paths with an MTU smaller than the minimum required IPv6 MTU
> size (1280 byte) - called atomic fragments.
> 
> See IETF I-D "Deprecating the Generation of IPv6 Atomic Fragments" [1]
> for more information and how this "feature" can be misused.
> 
> [1] https://tools.ietf.org/html/draft-ietf-6man-deprecate-atomfrag-generation-00
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Fernando Gont <fgont@si6networks.com>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Applied, thanks.

But any follow-ups to get rid of RTAX_FEATURE_ALLFRAG altogether are
not to be seriously considered in my opinion.
