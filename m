From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: wake up all assocs if sndbuf policy is
 per socket
Date: Tue, 08 Apr 2014 12:50:32 -0400 (EDT)
Message-ID: <20140408.125032.810691136561418545.davem@davemloft.net>
References: <1396964037-13245-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org, tgraf@suug.ch,
	nhorman@tuxdriver.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756079AbaDHQue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:50:34 -0400
In-Reply-To: <1396964037-13245-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue,  8 Apr 2014 15:33:57 +0200

>  [ When net-next opens up again, we need to think how
>    we can ideally make a new list interface and simplify
>    both open-coded list traversals. ]

I don't think you need a new list interface.

Instead, just have a back pointer to the sctp_sk() from the asoc, then
you can do normal list traversals over the asocs.
