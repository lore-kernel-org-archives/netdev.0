From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net / pktgen: Fix freezing problem
Date: Thu, 04 Feb 2010 14:00:54 -0800 (PST)
Message-ID: <20100204.140054.169192674.davem@davemloft.net>
References: <201002042250.58944.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, akpm@linux-foundation.org,
	ciprian.craciun@gmail.com
To: rjw@sisk.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002042250.58944.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 4 Feb 2010 22:50:58 +0100

> From: Rafael J. Wysocki <rjw@sisk.pl>
> Subject: Net / pktgen: Fix freezing problem
> 
> Add missing try_to_freeze() to one of the pktgen_thread_worker() code
> paths so that it doesn't block suspend/hibernation.
> 
> Fixes http://bugzilla.kernel.org/show_bug.cgi?id=15006
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Reported-and-tested-by: Ciprian Dorin Craciun <ciprian.craciun@gmail.com>

Applied, thanks a lot.
