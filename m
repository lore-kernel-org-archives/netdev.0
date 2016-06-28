From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: fix out-of-order cn_proc netlink message
 delivery
Date: Tue, 28 Jun 2016 08:49:19 -0400 (EDT)
Message-ID: <20160628.084919.306629083152756936.davem@davemloft.net>
References: <1466773532-16596-1-git-send-email-aaron@monkey.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zbr@ioremap.net, nuxi@vault24.org
To: aaron@monkey.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466773532-16596-1-git-send-email-aaron@monkey.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aaron Campbell <aaron@monkey.org>
Date: Fri, 24 Jun 2016 10:05:32 -0300

> The proc connector messages include a sequence number, allowing userspace
> programs to detect lost messages.  However, performing this detection is
> currently more difficult than necessary, since netlink messages can be
> delivered to the application out-of-order.  To fix this, leave pre-emption
> disabled during cn_netlink_send(), and use GFP_NOWAIT.
> 
> The following was written as a test case.  Building the kernel w/ make -j32
> proved a reliable way to generate out-of-order cn_proc messages.
 ...
> Signed-off-by: Aaron Campbell <aaron@monkey.org>

Applied.
