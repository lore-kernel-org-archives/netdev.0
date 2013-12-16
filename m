From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: revert misguided compiler warning fix
 on ipv6_exthdrs_len
Date: Sun, 15 Dec 2013 20:31:31 -0500 (EST)
Message-ID: <20131215.203131.1945457036600976154.davem@davemloft.net>
References: <CAPshTCj38XqrAMTKnGhw1bdWWrhHbzXpT8FNtDwd6_kJgLoeDg@mail.gmail.com>
	<20131215171806.GA1715@order.stressinduktion.org>
	<20131215172322.GB1715@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3LPBbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 20:31:33 -0500
In-Reply-To: <20131215172322.GB1715@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 15 Dec 2013 18:23:22 +0100

> On Sun, Dec 15, 2013 at 06:18:06PM +0100, Hannes Frederic Sowa wrote:
>> This essentlally reverts commit f52d81dc27c3456c702e83183035142c222acdc7
>> ("ipv6: fix compiler warning in ipv6_exthdrs_len") and silences the
>> warning with uninitialized_var.
> 
> David, please discard this. Jerry already posted a nicer cleanup.

I can't resolve these two patches in any reasonable way.

Specifically, whether I revert your patch or not, I cannot get Jerry's
patch to apply cleanly.

I can't figure out what Jerry's patch is against at all.
