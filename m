From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: fix a BUG() during initialization
Date: Tue, 23 Jun 2015 03:34:36 -0700 (PDT)
Message-ID: <20150623.033436.27435944821901354.davem@davemloft.net>
References: <1434716511-25657-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, imrep@amazon.de, msw@amazon.com
To: imrep.amz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434716511-25657-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Imre Palik <imrep.amz@gmail.com>
Date: Fri, 19 Jun 2015 14:21:51 +0200

> From: "Palik, Imre" <imrep@amazon.de>
> 
> Commit edafc132baac ("xen-netback: making the bandwidth limiter runtime settable")
> introduced the capability to change the bandwidth rate limit at runtime.
> But it also introduced a possible crashing bug.
> 
> If netback receives two XenbusStateConnected without getting the
> hotplug-status watch firing in between, then it will try to register the
> watches for the rate limiter again.  But this triggers a BUG() in the watch
> registration code.
> 
> The fix modifies connect() to remove the possibly existing packet-rate
> watches before trying to install those watches.  This behaviour is in line
> with how connect() deals with the hotplug-status watch.
> 
> Signed-off-by: Imre Palik <imrep@amazon.de>
> Cc: Matt Wilson <msw@amazon.com>

Applied, thank you.
