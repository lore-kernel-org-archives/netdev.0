From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ip: Support checksum returned in csmg
Date: Mon, 05 Jan 2015 16:11:42 -0500 (EST)
Message-ID: <20150105.161142.534428170803519086.davem@davemloft.net>
References: <1420488035-24866-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60467 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476AbbAEVLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:11:47 -0500
In-Reply-To: <1420488035-24866-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon,  5 Jan 2015 12:00:31 -0800

> This patch set allows the packet checksum for a datagram socket
> to be returned in csum data in recvmsg. This allows userspace
> to implement its own checksum over the data, for instance if an
> IP tunnel was be implemented in user space, the inner checksum
> could be validated.
> 
> Changes in this patch set:
>   - Move checksum conversion to inet_sock from udp_sock. This
>     generalizes checksum conversion for use with other protocols.
>   - Move IP cmsg constants to a header file and make processing
>     of the flags more efficient in ip_cmsg_recv
>   - Return checksum value in cmsg. This is specifically the unfolded
>     32 bit checksum of the full packet starting from the first byte
>     returned in recvmsg
> 
> Tested: Wrote a little server to get checksums in cmsg for UDP and
>         verfied correct checksum is returned.

This series looks fine, I just want two minor adjustments.  I'll
reply to the relevant patches.
