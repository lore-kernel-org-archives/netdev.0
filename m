From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-net V2 00/12] net/mlx5_core: Enhance flow steering
 support
Date: Sun, 10 Jan 2016 17:05:24 -0500 (EST)
Message-ID: <20160110.170524.1947409913228474436.davem@davemloft.net>
References: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, matanb@mellanox.com,
	maorg@mellanox.com, saeedm@mellanox.com, eranbe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbcAJWF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 17:05:26 -0500
In-Reply-To: <1452415189-27950-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 10 Jan 2016 10:39:37 +0200

> v1 --> v2 changes:
>   - made sure that service functions added in the IB driver are only static-fied 
>     on the last commit, to make sure bisection with -Werror works fine.

Please don't do this.  This looks rediculous.

Instead, if this kind of dependency exists in a source file, simply
add the new functions in the same commit that adds the usage of
them.
