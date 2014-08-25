From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 3/3] packet: make use of deferred TX queue
 flushing
Date: Sun, 24 Aug 2014 22:57:41 -0700 (PDT)
Message-ID: <20140824.225741.1546858244063296096.davem@davemloft.net>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHYF5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 01:57:42 -0400
In-Reply-To: <1408887738-7661-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 24 Aug 2014 15:42:18 +0200

> This adds a first use-case of deferred tail pointer flushing
> for AF_PACKET's TX_RING in QDISC_BYPASS mode.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

If last_queue changes, you'll need to force a flush, does that
end up happening with your changes here?  I really couldn't
tell for sure.
