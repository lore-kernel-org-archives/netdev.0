From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Mon, 19 Jan 2015 14:55:22 +0100
Message-ID: <1421675722.32277.3.camel@stressinduktion.org>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Fernando Gont <fgont@si6networks.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1421357665-2804-1-git-send-email-hagen@jauu.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Do, 2015-01-15 at 22:34 +0100, Hagen Paul Pfeifer wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I think this is the correct way forward on how to deal with atomic
fragments.

Hagen, do you submit patches to remove dst_allfrag/RTAX_FEATURE_ALLFRAG,
IPCORK_ALLFRAG, etc. for net-next, too?

Thanks,
Hannes
