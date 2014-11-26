From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] gue: Generalize remote checksum offload
Date: Wed, 26 Nov 2014 12:27:17 -0500 (EST)
Message-ID: <20141126.122717.455618670368268193.davem@davemloft.net>
References: <1416943280-28473-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbaKZR1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:27:19 -0500
In-Reply-To: <1416943280-28473-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 25 Nov 2014 11:21:18 -0800

> The remote checksum offload is generalized by creating a common
> function (remcsum_adjust) that does the work of modifying the
> checksum in remote checksum offload. This function can be called
> from normal or GRO path. GUE was modified to use this function.
> 
> Remote checksum offload is described in
> https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01
> 
> Tested by running 200 TCP_STREAM connections over GUE, did not see
> any problems with remote checksum offload enabled.

Series applied, thanks Tom.
