From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] TCP: Support configurable delayed-ack parameters.
Date: Tue, 19 Jun 2012 14:21:58 -0700 (PDT)
Message-ID: <20120619.142158.2026176205742396086.davem@davemloft.net>
References: <1340067163-29329-1-git-send-email-greearb@candelatech.com>
	<1340082688.7491.2299.camel@edumazet-glaptop>
	<4FE0A4CF.6000906@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, dbaluta@ixiacom.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463Ab2FSVV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:21:59 -0400
In-Reply-To: <4FE0A4CF.6000906@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 19 Jun 2012 09:11:59 -0700

> Dave..any opinion on this?  I'll be happy to get rid of the
> multiply caching if it's agreed that it should not be there.

I disagree fundamentally with the feature.

I can't believe for one minute that we can't do ACK stretching
dynamically using reasonable heuristics.

And, as Stephen said, we already have too many damn knobs.
