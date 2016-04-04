From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/8] add TX timestamping via cmsg
Date: Mon, 04 Apr 2016 15:52:22 -0400 (EDT)
Message-ID: <20160404.155222.503507246831715394.davem@davemloft.net>
References: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com, kafai@fb.com,
	soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756243AbcDDTwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 15:52:25 -0400
In-Reply-To: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Sat,  2 Apr 2016 23:08:05 -0400

> This patch series aim at enabling TX timestamping via cmsg.
> 
> Currently, to occasionally sample TX timestamping on a socket,
> applications need to call setsockopt twice: first for enabling
> timestamps and then for disabling them. This is an unnecessary
> overhead. With cmsg, in contrast, applications can sample TX
> timestamps per sendmsg().
> 
> This patch series adds the code for processing SO_TIMESTAMPING
> for cmsg's of the SOL_SOCKET level, and adds the glue code for
> TCP, UDP, and RAW for both IPv4 and IPv6. This implementation
> supports overriding timestamp generation flags (i.e.,
> SOF_TIMESTAMPING_TX_*) but not timestamp reporting flags.
> Applications must still enable timestamp reporting via
> setsockopt to receive timestamps.
> 
> This series does not change existing timestamping behavior for
> applications that are using socket options.
> 
> I will follow up with another patch to enable timestamping for
> active TFO (client-side TCP Fast Open) and also setting packet
> mark via cmsgs.
 ...
> Changes in v2:
>         - Replace u32 with __u32 in the documentation.
> 
> Changes in v3:
> 	- Fix the broken build for L2TP (due to changes
> 	  in IPv6).

Series applied, thanks.
