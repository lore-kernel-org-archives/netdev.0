From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: reset network header before passing to
 taps
Date: Thu, 07 Aug 2014 16:06:17 -0700 (PDT)
Message-ID: <20140807.160617.1417231506028535686.davem@davemloft.net>
References: <1407442967-2109-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53659 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755437AbaHGXGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:06:18 -0400
In-Reply-To: <1407442967-2109-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  7 Aug 2014 22:22:47 +0200

> netlink doesn't set any network header offset thus when the skb is
> being passed to tap devices via dev_queue_xmit_nit(), it emits klog
> false positives due to it being unset like:
> 
>   ...
>   [  124.990397] protocol 0000 is buggy, dev nlmon0
>   [  124.990411] protocol 0000 is buggy, dev nlmon0
>   ...
> 
> So just reset the network header before passing to the device; for
> packet sockets that just means nothing will change - mac and net
> offset hold the same value just as before.
> 
> Reported-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable.
