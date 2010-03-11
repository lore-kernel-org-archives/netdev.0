From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 12:12:39 -0800
Message-ID: <20100311121239.14944fd5@nehalam>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	<1268337450-6749-4-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50941 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606Ab0CKUUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:20:24 -0500
In-Reply-To: <1268337450-6749-4-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 20:57:29 +0100
Jan Engelhardt <jengelh@medozas.de> wrote:

> `ip -s link` shows interface counters truncated to 32 bit. This is
> because interface statistics are transported only in 32-bit quantity
> to userspace. This commit adds a new IFLA_STATS64 attribute that
> exports them in full 64 bit.
> 
> References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0215.html
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> 

What is the point since net_device_stats has only 32 bit counters.
The last time this came up the issue was is that is not possible
to atomically increment a 64 bit counter on most 32 bit platforms.
