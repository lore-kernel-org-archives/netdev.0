From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: icn: Fix potentially wrong string handling
Date: Tue, 01 Feb 2011 14:18:23 -0800 (PST)
Message-ID: <20110201.141823.59678888.davem@davemloft.net>
References: <1296419486-5482-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, tj@kernel.org, rostedt@goodmis.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: weil@mail.berlios.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296419486-5482-1-git-send-email-weil@mail.berlios.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Weil <weil@mail.berlios.de>
Date: Sun, 30 Jan 2011 21:31:26 +0100

> This warning was reported by cppcheck:
> drivers/isdn/icn/icn.c:1641: error: Dangerous usage of 'rev' (strncpy doesn't always 0-terminate it)
> 
> If strncpy copied 20 bytes, the destination string rev was not terminated.
> The patch adds one more byte to rev and makes sure that this byte is
> always 0.
> 
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>

Applied, thanks.
