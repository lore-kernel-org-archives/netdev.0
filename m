From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 3/4] ptp_clock: allow for it to be optional
Date: Thu, 20 Oct 2016 08:38:53 -0700
Message-ID: <20161020153853.jsvelztvr3bnlqmv@jtriplet-mobl2.jf.intel.com>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
 <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org>
 <20161020140601.GC2238@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161020140601.GC2238@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2016 at 04:06:02PM +0200, Richard Cochran wrote:
> On Wed, Oct 19, 2016 at 07:42:52PM -0400, Nicolas Pitre wrote:
> > +static inline void ptp_clock_event(struct ptp_clock *ptp,
> > +				   struct ptp_clock_event *event)
> > +{ (void)event; }
> 
> Just out of curiosity, why do you need that cast?
> 
> (I thought the kernel's gcc settings don't enable the warning for
> unused arguments.)

And if they did, wouldn't you need it for ptp as well?
