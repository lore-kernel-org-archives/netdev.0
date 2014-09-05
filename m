From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net-timestamp: only report sw timestamp if
 reporting bit is set
Date: Fri, 05 Sep 2014 15:03:15 -0700 (PDT)
Message-ID: <20140905.150315.472751844317741858.davem@davemloft.net>
References: <1409760078-25930-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaIEWDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:03:16 -0400
In-Reply-To: <1409760078-25930-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed,  3 Sep 2014 12:01:18 -0400

> The timestamping API has separate bits for generating and reporting
> timestamps. A software timestamp should only be reported for a packet
> when the packet has the relevant generation flag (SKBTX_..) set
> and the socket has reporting bit SOF_TIMESTAMPING_SOFTWARE set.
> 
> The second check was accidentally removed. Reinstitute the original
> behavior.
> 
> Tested:
>   Without this patch, Documentation/networking/txtimestamp reports
>   timestamps regardless of whether SOF_TIMESTAMPING_SOFTWARE is set.
>   After the patch, it only reports them when the flag is set.
> 
> Fixes: f24b9be5957b ("net-timestamp: extend SCM_TIMESTAMPING ancillary data struct")
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable, thanks Willem.
