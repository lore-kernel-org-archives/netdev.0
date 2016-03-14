From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SOCK_SEQPACKET socketpair must get SIGPIPE in AF_UNIX
 if one end is closed
Date: Mon, 14 Mar 2016 15:19:23 -0400 (EDT)
Message-ID: <20160314.151923.1878027262976947807.davem@davemloft.net>
References: <1457532623-125301-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, rweikusat@mobileactivedefense.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457532623-125301-1-git-send-email-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Wed,  9 Mar 2016 15:10:23 +0100

> According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
> socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if the
> socket is no longer connected.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Please format your Subject line properly, the format is:

	[PATCH] $SUBSYSTEM: $DESCRIPTION.

In this case "af_unx: " would be a proper subsystem marker.

Also,

> ---
> I used the following program to check the kernel behavior:

Please include this in your commit message rather than cutting it out
using the "---" marker, as it will help people in the future
understand your change and how you tested it.  More information is
always better than less information.

Thanks.
