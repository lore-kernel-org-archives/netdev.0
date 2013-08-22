From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] bridge: inherit slave devices needed_headroom
Date: Wed, 21 Aug 2013 20:41:18 -0700 (PDT)
Message-ID: <20130821.204118.1256595635757846005.davem@davemloft.net>
References: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	eric.dumazet@gmail.com, vyasevic@redhat.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab3HVDlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:41:19 -0400
In-Reply-To: <1376990505-15708-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Tue, 20 Aug 2013 10:21:45 +0100

> Some slave devices may have set a dev->needed_headroom value which is
> different than the default one, most likely in order to prepend a
> hardware descriptor in front of the Ethernet frame to send. Whenever a
> new slave is added to a bridge, ensure that we update the
> needed_headroom value accordingly to account for the slave
> needed_headroom value.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

This looks fine to me, but I'd like to see either Eric, Stephen, or
Vlad review this before I apply it.
