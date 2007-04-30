From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC] [PATCH] [XFRM]: Restrict upper layer information by bundle.
Date: Tue, 01 May 2007 01:30:21 +0900
Message-ID: <20070501011930.AC41.NAKAM@linux-ipv6.org>
References: <11758443392651-git-send-email-nakam@linux-ipv6.org> <20070430.003437.57159715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:35347 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1946351AbXD3Q3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 12:29:32 -0400
In-Reply-To: <20070430.003437.57159715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 30 Apr 2007 00:34:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Date: Fri,  6 Apr 2007 16:25:39 +0900
> 
> > On MIPv6 usage, XFRM sub policy is enabled.
> > When main (IPsec) and sub (MIPv6) policy selectors have the same
> > address set but different upper layer information (i.e. protocol
> > number and its ports or type/code), multiple bundle should be created.
> > However, currently we have issue to use the same bundle created for
> > the first time with all flows covered by the case.
> > 
> > It is useful for the bundle to have the upper layer information
> > to be restructured correctly if it does not match with the flow.
> > 
> > 1. Bundle was created by two policies
> > Selector from another policy is added to xfrm_dst.
> > If the flow does not match the selector, it goes to slow path to
> > restructure new bundle by single policy.
> > 
> > 2. Bundle was created by one policy
> > Flow cache is added to xfrm_dst as originated one. If the flow does
> > not match the cache, it goes to slow path to try searching another
> > policy.
> > 
> > Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> This is an OK solution for the problem for now.
> 
> My senses tell me that there is probably some cleaner way to
> handle this problem.  If you come up with a better idea for it,
> please feel free to bounce your ideas to me.

I get it. It is added to my TODOs to find another way (which may include
design level change) to achive it.

Thank you,

-- 
Masahide NAKAMURA

