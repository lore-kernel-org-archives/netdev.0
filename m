From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: do xfrm transform after nat if necessary
Date: Mon, 03 Nov 2014 14:42:34 -0500 (EST)
Message-ID: <20141103.144234.1037182010018495486.davem@davemloft.net>
References: <54570A2F.2070206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbaKCTmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:42:37 -0500
In-Reply-To: <54570A2F.2070206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Mon, 3 Nov 2014 12:53:03 +0800

> 
> 
> In function nf_nat_ipv6_out, after nat is done, nf_xfrm_me_harder()
> will be called to look up xfrm dst.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

This is far from sufficient of a commit log message for a change that
is as serious and has as many implications as this one.

You haven't answered many questions, first of which in my mind is
why we are bypassing all of the fragmentation checks?

We're also bypassing ip6_finish_output2() which does multicast and
hooks up the neighbour.

IPV4 doesn't do this, why doesn't it have the same supposed problem
you are trying to solve?

It is not even clear to me what the problem is, because your commit
message is way too terse.
