From: David Miller <davem@davemloft.net>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 01:51:30 -0700 (PDT)
Message-ID: <20060918.015130.34760190.davem@davemloft.net>
References: <20060917101101.GA30461@outpost.ds9a.nl>
	<20060917205351.4f691c4e@localhost.localdomain>
	<20060917122153.GA2932@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49566
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965580AbWIRIvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 04:51:35 -0400
To: bert.hubert@netherlabs.nl
In-Reply-To: <20060917122153.GA2932@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: bert hubert <bert.hubert@netherlabs.nl>
Date: Sun, 17 Sep 2006 14:21:53 +0200

> Operators, distributors and even people who've been doing kernel stuff for
> more than a decade expect to be able to compile in (experimental) policies,
> and not have a *random* one of them enabled by default!

We created TCP_CONG_ADVANCED for a purpose.  If you turn that
thing on, you get full control but if something breaks you get
to keep the pieces.

Quite frankly, just about everyone should not enable TCP_CONG_ADVANCED
at all.  And quite likely thie applies even distribution vendors.
