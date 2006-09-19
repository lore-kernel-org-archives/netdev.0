From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 10:28:53 -0700
Message-ID: <20060919102853.7db3cac1@localhost.localdomain>
References: <20060918214104.3824a2e2@localhost.localdomain>
	<200609191203.51045.ak@suse.de>
	<20060919123534.GC7000@c3po.0xdef.net>
	<20060919.091037.110907025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, ak@suse.de, bert.hubert@netherlabs.nl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5059 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030370AbWISR3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:29:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.091037.110907025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Sep 2006 09:10:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Hagen Paul Pfeifer <hagen@jauu.net>
> Date: Tue, 19 Sep 2006 14:35:35 +0200
> 
> > BTW: BIC is sometimes to aggressive in comparison to standard tcp
> > behaviour (e.g. in short RTT environments) - this is an known
> > issue. Why not cubic as the default one?
> 
> We may change over to CUBIC as the default in 2.6.19, I wanted
> CUBIC to sit around in the tree for a while in case some major
> issues came up first.

I was going to do this for 2.6.19 as well, but wanted more discussion
and also do it as a separate step from the config changes.

-- 
Stephen Hemminger <shemminger@osdl.org>
