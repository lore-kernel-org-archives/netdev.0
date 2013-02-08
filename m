From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] two small fixes for sctp key usage
Date: Fri, 08 Feb 2013 14:55:35 -0500 (EST)
Message-ID: <20130208.145535.2028003181646685456.davem@davemloft.net>
References: <cover.1360327229.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946795Ab3BHTzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:55:37 -0500
In-Reply-To: <cover.1360327229.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  8 Feb 2013 14:04:33 +0100

> Cryptographically used keys should be zeroed out when our session
> ends resp. memory is freed, thus do not leave them somewhere in the
> memory.
> 
> Daniel Borkmann (2):
>   net: sctp: sctp_setsockopt_auth_key: use kzfree instead of kfree
>   net: sctp: sctp_endpoint_free: zero out secret key data

Applied and queued up for -stable, thanks.
