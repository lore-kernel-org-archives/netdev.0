From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/4] ptp_clock: allow for it to be optional
Date: Thu, 20 Oct 2016 16:06:02 +0200
Message-ID: <20161020140601.GC2238@netboy>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
 <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 07:42:52PM -0400, Nicolas Pitre wrote:
> +static inline void ptp_clock_event(struct ptp_clock *ptp,
> +				   struct ptp_clock_event *event)
> +{ (void)event; }

Just out of curiosity, why do you need that cast?

(I thought the kernel's gcc settings don't enable the warning for
unused arguments.)

Thanks,
Richard
