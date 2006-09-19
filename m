From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 09:10:37 -0700 (PDT)
Message-ID: <20060919.091037.110907025.davem@davemloft.net>
References: <20060918214104.3824a2e2@localhost.localdomain>
	<200609191203.51045.ak@suse.de>
	<20060919123534.GC7000@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, shemminger@osdl.org, bert.hubert@netherlabs.nl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65181
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750793AbWISQKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 12:10:46 -0400
To: hagen@jauu.net
In-Reply-To: <20060919123534.GC7000@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Tue, 19 Sep 2006 14:35:35 +0200

> BTW: BIC is sometimes to aggressive in comparison to standard tcp
> behaviour (e.g. in short RTT environments) - this is an known
> issue. Why not cubic as the default one?

We may change over to CUBIC as the default in 2.6.19, I wanted
CUBIC to sit around in the tree for a while in case some major
issues came up first.
