From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: tcp_probe: adapt tbuf size for recent
 changes
Date: Wed, 04 Sep 2013 00:55:03 -0400 (EDT)
Message-ID: <20130904.005503.542805290897839216.davem@davemloft.net>
References: <1378225442-6676-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761399Ab3IDEzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 00:55:04 -0400
In-Reply-To: <1378225442-6676-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  3 Sep 2013 18:24:02 +0200

> With recent changes in tcp_probe module (e.g. f925d0a62d ("net: tcp_probe:
> add IPv6 support")) we also need to take into account that tbuf needs to
> be updated as format string will be further expanded. tbuf sits on the stack
> in tcpprobe_read() function that is invoked when user space reads procfs
> file /proc/net/tcpprobe, hence not fast path as in jtcp_rcv_established().
> Having a size similarly as in sctp_probe module of 256 bytes is fully
> sufficient for that, we need theoretical maximum of 252 bytes otherwise we
> could get truncated.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
