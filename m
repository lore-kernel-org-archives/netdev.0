From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-timestamp: SOCK_RAW and PING timestamping
Date: Tue, 15 Jul 2014 16:33:02 -0700 (PDT)
Message-ID: <20140715.163302.175573076245211912.davem@davemloft.net>
References: <1405374906-4657-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760378AbaGOXdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:33:04 -0400
In-Reply-To: <1405374906-4657-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon, 14 Jul 2014 17:55:06 -0400

> Add SO_TIMESTAMPING to sockets of type PF_INET[6]/SOCK_RAW:
> 
> Add the necessary sock_tx_timestamp calls to the datapath for RAW
> sockets (ping sockets already had these calls).
> 
> Fix the IP output path to pass the timestamp flags on the first
> fragment also for these sockets. The existing code relies on
> transhdrlen != 0 to indicate a first fragment. For these sockets,
> that assumption does not hold.
> 
> This fixes http://bugzilla.kernel.org/show_bug.cgi?id=77221
> 
> Tested SOCK_RAW on IPv4 and IPv6, not PING.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
