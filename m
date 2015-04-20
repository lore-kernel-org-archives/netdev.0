From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/10] ipv6: Only create RTF_CACHE route after
 encountering pmtu exception
Date: Mon, 20 Apr 2015 14:29:45 -0400 (EDT)
Message-ID: <20150420.142945.669671280128419399.davem@davemloft.net>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbDTS3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 14:29:47 -0400
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 10 Apr 2015 18:54:03 -0700

> This series is to avoid creating a RTF_CACHE route whenever we are consulting
> the fib6 tree with a new destination.  Instead, only create RTF_CACHE route
> when we see a pmtu exception.

Please separate out the pure bug fixes from this series and submit them for
inclusion into 'net', thanks.
