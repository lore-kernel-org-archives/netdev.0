From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6/addrlabel: fix ip6addrlbl_get()
Date: Tue, 22 Dec 2015 15:58:40 -0500 (EST)
Message-ID: <20151222.155840.2274587303611570782.davem@davemloft.net>
References: <1450691685-29413-1-git-send-email-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: aryabinin@virtuozzo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450691685-29413-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Date: Mon, 21 Dec 2015 12:54:45 +0300

> ip6addrlbl_get() has never worked. If ip6addrlbl_hold() succeeded,
> ip6addrlbl_get() will exit with '-ESRCH'. If ip6addrlbl_hold() failed,
> ip6addrlbl_get() will use about to be free ip6addrlbl_entry pointer.
> 
> Fix this by inverting ip6addrlbl_hold() check.
> 
> Fixes: 2a8cc6c89039 ("[IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

Applied and queued up for -stable, thanks.
