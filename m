From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Thu, 02 Jan 2014 19:30:26 -0500 (EST)
Message-ID: <20140102.193026.342067029221260651.davem@davemloft.net>
References: <1388423651-12481-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbaACAa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:30:28 -0500
In-Reply-To: <1388423651-12481-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Mon, 30 Dec 2013 09:14:11 -0800

> +extern struct list_head offload_base;

Please add a programmatical interface to do the lookups you need
rather than exporting this symbol externally.

As best I can tell you're trying to "find gro receive by type"
and "find gro complete by type".  So function signatures ought
to look something like.

struct packet_offload *gro_find_receive_by_type(__be16 type);
struct packet_offload *gro_find_complete_by_type(__be16 type);

Thanks.
