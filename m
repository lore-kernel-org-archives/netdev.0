From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sctp: minor: remove dead code from
 sctp_packet
Date: Mon, 22 Apr 2013 16:25:48 -0400 (EDT)
Message-ID: <20130422.162548.208159519580804410.davem@davemloft.net>
References: <1366358377-7623-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab3DVUZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:25:50 -0400
In-Reply-To: <1366358377-7623-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 19 Apr 2013 09:59:37 +0200

> struct sctp_packet is currently embedded into sctp_transport or
> sits on the stack as 'singleton' in sctp_outq_flush(). Therefore,
> its member 'malloced' is always 0, thus a kfree() is never called.
> Because of that, we can just remove this code.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
