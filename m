From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/12] mISDN: fix race in timer canceling on module
 unloading
Date: Fri, 14 Dec 2012 13:16:09 -0500 (EST)
Message-ID: <20121214.131609.2271247275899669616.davem@davemloft.net>
References: <20121214110229.11019.63713.stgit@zurg>
	<20121214110236.11019.98301.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn@linux-pingi.de
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121214110236.11019.98301.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 14 Dec 2012 15:02:36 +0400

> Using timer_pending() without additional syncronization is racy,
> del_timer_sync() must be used here for waiting in-flight handler.
> Bug caught with help from "debug-objects" during random insmod/rmmod.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied.
