From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net v2 1/1] net: batman-adv: Treat NET_XMIT_CN as
 transmit successfully
Date: Mon, 21 Nov 2016 12:09:15 +0100
Message-ID: <20161121110915.GB22120@breakpoint.cc>
References: <1479725922-5112-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37622 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753528AbcKULL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 06:11:59 -0500
Content-Disposition: inline
In-Reply-To: <1479725922-5112-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fgao@ikuai8.com <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The tc could return NET_XMIT_CN as one congestion notification, but
> it does not mean the packet is lost. Other modules like ipvlan,
> macvlan, and others treat NET_XMIT_CN as success too.
> 
> So batman-adv should add the NET_XMIT_CN check.

"The tc could return NET_XMIT_CN as one congestion notification, but
it means another packet got dropped. Other modules like batman do not
treat NET_XMIT_CN as success, so modules like ipvlan, macvlan, ..
should ignore it as well."

What I am asking is:
Are you sure adding NET_XMIT_CN handling everywhere is the right way to
resolve the inconsistency?
