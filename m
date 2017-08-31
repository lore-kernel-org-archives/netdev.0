From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 24/25] net/cdc_ncm: Replace tasklet with softirq hrtimer
Date: Thu, 31 Aug 2017 15:33:53 +0200
Message-ID: <20170831133353.GB22739@kroah.com>
References: <20170831105725.809317030@linutronix.de>
 <20170831105827.479650817@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Christoph Hellwig <hch@lst.org>, keescook@chromium.org,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Oliver Neukum <oliver@neukum.org>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Anna-Maria Gleixner <anna-maria@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170831105827.479650817@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 12:23:46PM -0000, Anna-Maria Gleixner wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> 
> The bh tasklet is used in invoke the hrtimer (cdc_ncm_tx_timer_cb) in
> softirq context. This can be also achieved without the tasklet but with
> CLOCK_MONOTONIC_SOFT as hrtimer base.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: linux-usb@vger.kernel.org
> Cc: netdev@vger.kernel.org


Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
