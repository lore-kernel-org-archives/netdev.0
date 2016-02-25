From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: jme: fix suspend/resume on JMC260
Date: Wed, 24 Feb 2016 23:58:56 -0500 (EST)
Message-ID: <20160224.235856.242530723940439026.davem@davemloft.net>
References: <1456239844-4109-1-git-send-email-diego.viola@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, richard.weinberger@gmail.com,
	pavel@ucw.cz, rjw@rjwysocki.net, valdis.kletnieks@vt.edu
To: diego.viola@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456239844-4109-1-git-send-email-diego.viola@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Diego Viola <diego.viola@gmail.com>
Date: Tue, 23 Feb 2016 12:04:04 -0300

> The JMC260 network card fails to suspend/resume because the call to
> jme_start_irq() was too early, moving the call to jme_start_irq() after
> the call to jme_reset_link() makes it work.
> 
> Prior this change suspend/resume would fail unless /sys/power/pm_async=0
> was explicitly specified.
> 
> Relevant bug report: https://bugzilla.kernel.org/show_bug.cgi?id=112351
> 
> Signed-off-by: Diego Viola <diego.viola@gmail.com>

Applied and queued up for -stable, thanks.
