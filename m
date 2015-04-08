From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: ip_tunnel: use net namespace from
 rtable not socket
Date: Wed, 08 Apr 2015 12:09:58 -0400 (EDT)
Message-ID: <20150408.120958.1217271670558706137.davem@davemloft.net>
References: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754102AbbDHQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:09:59 -0400
In-Reply-To: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  8 Apr 2015 17:01:22 +0200

> The socket parameter might legally be NULL, thus sock_net is sometimes
> causing a NULL pointer dereference. Using net_device pointer in dst_entry
> is more reliable.
> 
> Fixes: b6a7719aedd7e5c ("ipv4: hash net ptr into fragmentation bucket selection")
> Reported-by: Rick Jones <rick.jones2@hp.com>
> Cc: Rick Jones <rick.jones2@hp.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
