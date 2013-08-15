From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: IP_TOS and IP_TTL can be specified
 as ancillary data
Date: Thu, 15 Aug 2013 13:51:02 -0700 (PDT)
Message-ID: <20130815.135102.1979894992456635853.davem@davemloft.net>
References: <cover.1376494030.git.ffusco@redhat.com>
	<cover.1376494030.git.ffusco@redhat.com>
	<92ffe52615a79259cd7cc120e504a9cf41dd546e.1376494031.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab3HOUvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 16:51:03 -0400
In-Reply-To: <92ffe52615a79259cd7cc120e504a9cf41dd546e.1376494031.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Wed, 14 Aug 2013 17:48:38 +0200

> +	__s16			ttl;
> +	__s16			tos;

You're range validating these values to make sure they are always
between 1 and 255, inclusive.

Why use a 16-bit value, and in particular a signed one?  That makes
absolutely no sense at all.

These fit perfectly in a "u8" so use that instead.
