From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/: misc possible cleanups
Date: Mon, 27 Dec 2004 20:04:24 -0800
Message-ID: <20041227200424.557a5902.davem@davemloft.net>
References: <20041215005139.GJ23151@stusta.de>
	<20041227191535.5edce690.davem@davemloft.net>
	<20041228033617.GI5345@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262063AbUL1EJK@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041228033617.GI5345@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Dec 2004 04:36:17 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> tcp_done doesn't call tcp_clear_xmit_timer, it calls 
> tcp_clear_xmit_timers (note the s) which is not an inline but an 
> EXPORT_SYMBOL'ed function in tcp_timer.c.

My bad, I'll re-review your patch and apply it unless
I find some problem.
