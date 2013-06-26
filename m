From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix ecmp lookup when oif is specified
Date: Wed, 26 Jun 2013 15:19:29 -0700 (PDT)
Message-ID: <20130626.151929.2241949243651761177.davem@davemloft.net>
References: <1371198778-26099-1-git-send-email-nicolas.dichtel@6wind.com>
	<20130623.184018.934611809597741522.davem@davemloft.net>
	<51C87768.7090008@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab3FZWTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:19:30 -0400
In-Reply-To: <51C87768.7090008@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 24 Jun 2013 18:44:24 +0200

> Will you accept the patch if I remove only the check of oif argument
> in ip6_pol_route() (and leave ip6_pol_route_lookup() untouched).
> 
> My goal was only to have ECMP working in the forwarding case.

Yes, if you make it such that, like ipv4, oif is respected for output
route lookups.
