From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH  v2 13/13] net: ethernet: ti: cpts: fix overflow check
 period
Date: Wed, 30 Nov 2016 10:12:58 +0100
Message-ID: <20161130091258.GA28680@localhost.localdomain>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-14-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128230337.6731-14-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:03:37PM -0600, Grygorii Strashko wrote:
> The CPTS drivers uses 8sec period for overflow checking with
> assumption that CPTS retclk will not exceed 500MHz. But that's not
> true on some TI platforms (Kesytone 2). As result, it is possible that
> CPTS counter will overflow more than once between two readings.
> 
> Hence, fix it by selecting overflow check period dynamically as
> max_sec_before_overflow/2, where
>  max_sec_before_overflow = max_counter_val / rftclk_freq.
> 
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
