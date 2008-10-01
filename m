From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,RESEND] XFRM,IPv6: initialize
 ip6_dst_blackhole_ops.kmem_cachep
Date: Wed, 01 Oct 2008 02:38:31 -0700 (PDT)
Message-ID: <20081001.023831.45381902.davem@davemloft.net>
References: <87prmuvnmt.fsf@natisbad.org>
	<939d53060809250221p171eb282v4451721464bd35a1@mail.gmail.com>
	<873ajg1xa0.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben.thery@gmail.com
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbYJAJim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:38:42 -0400
In-Reply-To: <873ajg1xa0.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Wed, 01 Oct 2008 11:26:31 +0200

> With the switch to a default value of 1 for xfrm_larval_drop in commit
> 28faa979746b2352cd78a376bf9f52db953bda46 (ipsec: Make xfrm_larval_drop
> default to 1), what seems to be a bug manage to surface on one of my
> test box running today's net-next (*).
> 
> When xfrm_tmpl_resolve() returns -EAGAIN in __xfrm_lookup(), the caller
> is returned -EREMOTE and is expected to install a blackhole route. For
> IPv6, the call to dst_alloc(&ip6_dst_blackhole_ops) performed by
> ip6_dst_blackhole() produces the error provided below, because
> kmem_cachep attribute seems to be uninitialized. This does not happen
> when xfrm_larval_drop is set to 0.
> 
> The patch below against today's net-next. Benjamin (in CC) reported on
> the introduction of the bug (f2fc6a54585a1be6669613a31fbaba2ecbadcd36)
> while adding network namespaces support to ipv6 routes.

Applied to net-2.6, thanks Arnaud!
