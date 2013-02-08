From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: sctp_auth_make_key_vector: use
 sctp_auth_create_key
Date: Fri, 08 Feb 2013 17:57:49 -0500 (EST)
Message-ID: <20130208.175749.439352484305130110.davem@davemloft.net>
References: <cover.1360314390.git.dborkman@redhat.com>
	<783e1129996c3f09c7da121f5dd91c8ac7ba5baa.1360314390.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947211Ab3BHW5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:57:51 -0500
In-Reply-To: <783e1129996c3f09c7da121f5dd91c8ac7ba5baa.1360314390.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  8 Feb 2013 10:22:58 +0100

> In sctp_auth_make_key_vector, we allocate a temporary sctp_auth_bytes
> structure with kmalloc instead of the sctp_auth_create_key allocator.
> Change this to sctp_auth_create_key as it is the case everywhere else,
> so that we also can properly free it via sctp_auth_key_put. This makes
> it easier for future code changes in the structure and allocator itself,
> since a single API is consistently used for this purpose. Also, by
> using sctp_auth_create_key we're doing sanity checks over the arguments.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
