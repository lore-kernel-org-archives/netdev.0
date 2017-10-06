From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6: Convert icmpv6_push_pending_frames to void
Date: Fri, 06 Oct 2017 09:52:46 -0700 (PDT)
Message-ID: <20171006.095246.557143304896380730.davem@davemloft.net>
References: <14612f639009193e561bcdb11c5ef5b6f12830ed.1507272313.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        devtimhansen@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14612f639009193e561bcdb11c5ef5b6f12830ed.1507272313.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu,  5 Oct 2017 23:46:14 -0700

> commit cc71b7b07119 ("net/ipv6: remove unused err variable on
> icmpv6_push_pending_frames") exposed icmpv6_push_pending_frames
> return value not being used.
> 
> Remove now unnecessary int err declarations and uses.
> 
> Miscellanea:
> 
> o Remove unnecessary goto and out: labels
> o Realign arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
