From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net/bonding: adjust codingstyle for
 bond_3ad files
Date: Wed, 11 May 2011 17:28:14 -0700
Message-ID: <20110511172814.714e2f2a@nehalam>
References: <20110511225208.GA18851@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, Joe Perches <joe@perches.com>,
	kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Nicolas Kaiser <nikai@nikai.net>
To: aquini@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56392 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470Ab1ELA2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 20:28:17 -0400
In-Reply-To: <20110511225208.GA18851@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2011 19:52:21 -0300
Rafael Aquini <aquini@linux.com> wrote:

> Howdy,
> 
> While I was studying what bond_3ad has under its hood, I realized its coding
> style did not follow all Documentation/CodingStyle recommendations. As a tiny
> collaboration I did some mods there, in an attempt to make that code stick as
> closely as possible with Kernel's coding style. Also, Nicolas Kaiser has kindly
> suggested some conditional simplifications integrated in this patch.
> Modifications:
>         * switched all comments from C99-style to C89-style;
>         * replaced MAC_ADDRESS_COMPARE macro for compare_ether_addr();
> 	* print info out on unexpected status checkings;
>         * simplify conditionals:
> 		(a || (!a && !b)) => (a || !b)
> 		(!(!a && b)) => (a || !b)
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
> Signed-off-by: Rafael Aquini <aquini@linux.com>

This should be split into three separate patches.

Always assume your change will break something for somebody and it will
be necessary for some later investigation to bisect out the cause.



-- 
