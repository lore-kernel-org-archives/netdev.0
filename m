From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: sctp: Fix a_rwnd/rwnd management to
 reflect real state of the receiver's buffer"
Date: Mon, 14 Apr 2014 16:48:39 -0400 (EDT)
Message-ID: <20140414.164839.2032159104530481155.davem@davemloft.net>
References: <1397504717-19566-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	matija.glavinic-pecotic.ext@nsn.com, alexander.sverdlin@nsn.com,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaDNUsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 16:48:41 -0400
In-Reply-To: <1397504717-19566-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 14 Apr 2014 21:45:17 +0200

> This reverts commit ef2820a735f7 ("net: sctp: Fix a_rwnd/rwnd management
> to reflect real state of the receiver's buffer") as it introduced a
> serious performance regression on SCTP over IPv4 and IPv6, though a not
> as dramatic on the latter. Measurements are on 10Gbit/s with ixgbe NICs.
> 
> Current state:
 ...
> With the reverted patch applied, the SCTP/IPv4 performance is back
> to normal on latest upstream for IPv4 and IPv6 and has same throughput
> as 3.4.2 test kernel, steady and interval reports are smooth again.
> 
> Fixes: ef2820a735f7 ("net: sctp: Fix a_rwnd/rwnd management to reflect real state of the receiver's buffer")
> Reported-by: Peter Butler <pbutler@sonusnet.com>
> Reported-by: Dongsheng Song <dongsheng.song@gmail.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Tested-by: Peter Butler <pbutler@sonusnet.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable.
