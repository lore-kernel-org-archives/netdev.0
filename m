From: Patrick McHardy <kaber@trash.net>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Thu, 21 Apr 2011 10:57:58 +0200
Message-ID: <4DAFF196.6040505@trash.net>
References: <20110404194856.GA3720@dannf.org> <4D9A23BC.4010505@trash.net>	 <1301949477.3021.55.camel@edumazet-laptop>	 <1301957293.3021.191.camel@edumazet-laptop>	 <1301984679.3021.655.camel@edumazet-laptop>	 <1301987879.3021.714.camel@edumazet-laptop>	 <20110406162547.GA3064@dannf.org>	 <1302108258.3209.117.camel@edumazet-laptop> <1302108567.3209.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: dann frazier <dannf@dannf.org>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42108 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab1DUI6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 04:58:01 -0400
In-Reply-To: <1302108567.3209.121.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.04.2011 18:49, Eric Dumazet wrote:
> [PATCH] netfilter: fix ebtables
> 
> commit 255d0dc34068a976 (netfilter: x_table: speedup compat operations)
> made ebtables not working anymore.
> 
> 1) xt_compat_calc_jump() is not an exact match lookup
> 2) compat_table_info() has a typo in xt_compat_init_offsets() call
> 3) compat_do_replace() misses a xt_compat_init_offsets() call


Applied, thanks Eric.
