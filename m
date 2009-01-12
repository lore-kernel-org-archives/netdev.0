From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [GIT PULL, resend] async_tx/dmaengine update for 2.6.29
Date: Mon, 12 Jan 2009 10:45:02 -0700
Message-ID: <e9c3a7c20901120945r2728e6d3oc9237249d748f8dd@mail.gmail.com>
References: <20090112121539.GA6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, hskinnemoen@atmel.com,
	maciej.sosnowski@intel.com, g.liakhovetski@gmx.de,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, "David S. Miller" <davem@davemloft.net>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:6264 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbZALRpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 12:45:04 -0500
In-Reply-To: <20090112121539.GA6058@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 5:15 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> net/core/dev.c                        |  149 +------
>> net/ipv4/tcp.c                        |    5 +-
>> net/ipv4/tcp_input.c                  |    2 +-
>> net/ipv4/tcp_ipv4.c                   |    2 +-
>> net/ipv6/tcp_ipv6.c                   |    2 +-
>
> Wouldn't it be better for these changes to go through the net
> tree?
>

It was awkward to separate the reformatting of the core api from its
users.  In this exceptional case these changes were limited to areas
inside #ifdef CONFIG_DMA_ENGINE/CONFIG_NET_DMA.

In general, Maciej and I send purely incremental patches through the
net tree [1].

Regards,
Dan

[1]: http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=649274d993212e7c23c0cb734572c2311c200872
