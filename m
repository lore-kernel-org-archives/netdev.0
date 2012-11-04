From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] Avoid 'statement with no effect' compiler warnings
Date: Sun, 04 Nov 2012 01:00:43 -0500 (EST)
Message-ID: <20121104.010043.1842614952525101679.davem@davemloft.net>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
	<1351980150-24145-10-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: lee.jones@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351980150-24145-10-git-send-email-lee.jones@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lee Jones <lee.jones@linaro.org>
Date: Sat,  3 Nov 2012 23:02:30 +0100

> Instead of issuing (0) statements when !CONFIG_SYSFS which will cause
> 'warning: ', we'll use inline statements instead. This will effectively
> do the same thing, but suppress any unnecessary warnings.
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: bridge@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Lee Jones <lee.jones@linaro.org>

Applied, but please use more informative subject lines.

You should prefix your subject line after [PATCH ...] with
the name of the subsystem you are touching, a ": " then
the headline description.

So here you would have used "bridge: " and that's what I added when I
commited this patch.
