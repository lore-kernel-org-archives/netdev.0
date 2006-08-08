From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 00:01:10 -0700 (PDT)
Message-ID: <20060808.000110.110010976.davem@davemloft.net>
References: <200608080711.06788.ak@suse.de>
	<20060807.231834.48498773.davem@davemloft.net>
	<200608080853.03510.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dev@sw.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63674
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932481AbWHHHBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 03:01:07 -0400
To: ak@suse.de
In-Reply-To: <200608080853.03510.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Tue, 8 Aug 2006 08:53:03 +0200

> That's still too big. Consider a 2TB machine, with all memory in LOWMEM.

Andi I agree with you, route.c should pass in a suitable limit.
I'm just suggesting a fix for a seperate problem.
