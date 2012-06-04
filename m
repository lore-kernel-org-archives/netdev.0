From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] net/hyperv: Use wait_event on outstanding sends
 during device removal
Date: Mon, 04 Jun 2012 11:51:19 -0400 (EDT)
Message-ID: <20120604.115119.568655178193939719.davem@davemloft.net>
References: <1338820532-2345-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338820532-2345-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon,  4 Jun 2012 07:35:31 -0700

> This patch is targeting net-next tree (when it's available for check in).
> 
> Haiyang Zhang (1):
>   net/hyperv: Use wait_event on outstanding sends during device removal

Why in the world are you doing this?

This patch you are already asking me to apply to the 'net' tree, and
changes already will automatically propagate from 'net' to
'net-next' the next time I merge those trees.

So you never need to submit bug fixes twice, once for 'net' and
once for 'net-next' so please do not do it.
