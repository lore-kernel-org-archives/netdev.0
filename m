From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp_clock: future-proofing drivers against PTP subsystem
 becoming optional
Date: Wed, 21 Sep 2016 10:45:42 +0200
Message-ID: <20160921084542.GB27145@localhost.localdomain>
References: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 07:25:58PM -0400, Nicolas Pitre wrote:
> 
> Drivers must be ready to accept NULL from ptp_clock_register() if the
> PTP clock subsystem is configured out.
> 
> This patch documents that and ensures that all drivers cope well
> with a NULL return.
> 
> Signed-off-by: Nicolas Pitre <nico@linaro.org>
> Reviewed-by: Eugenia Emantayev <eugenia@mellanox.com>
> 
> ---
> 
> Let's have the basics merged now and work out the actual Kconfig issue 
> separately. Richard, if you agree with this patch, I think this could go 
> via the netdev tree.

It looks ok to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
