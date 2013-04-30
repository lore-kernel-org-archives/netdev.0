From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/3] unix/stream: fix peeking with an offset larger
 than data in queue
Date: Tue, 30 Apr 2013 00:44:19 -0400 (EDT)
Message-ID: <20130430.004419.627894415518165601.davem@davemloft.net>
References: <kll5si$544$1@ger.gmane.org>
	<1367271734-14379-1-git-send-email-bpoirier@suse.de>
	<1367271734-14379-3-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, xemul@parallels.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367271734-14379-3-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Mon, 29 Apr 2013 17:42:14 -0400

> Currently, peeking on a unix stream socket with an offset larger than len of
> the data in the sk receive queue returns immediately with bogus data.
> 
> This patch fixes this so that the behavior is the same as peeking with no
> offset on an empty queue: the caller blocks.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Applied.
