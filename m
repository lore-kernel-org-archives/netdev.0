From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Thu, 16 Jun 2016 16:59:30 -0700 (PDT)
Message-ID: <20160616.165930.1926303970829996171.davem@davemloft.net>
References: <2c081044-0861-8a84-f4ae-88c60c4ddc67@cumulusnetworks.com>
	<20160616.141805.201276959937562482.davem@davemloft.net>
	<0f3516fc-9108-58a3-88fa-49a80a829acc@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org, ja@ssi.bg
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561AbcFPX7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:59:33 -0400
In-Reply-To: <0f3516fc-9108-58a3-88fa-49a80a829acc@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 16 Jun 2016 23:39:12 +0200

> Most of the time a new attribute that gets added to flow4i only
> decreases the scope of the actual lookup, thus a missing attribute
> doesn't necessarily indicate a bug.

That's true, and it works well so long as the value zero provides
the behavior that existed before the new flow key was added.
