From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces
 with "ktime_t" type
Date: Fri, 20 Mar 2015 07:26:03 +0100
Message-ID: <20150320062603.GC4417@localhost.localdomain>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <1426743909-24335-3-git-send-email-baolin.wang@linaro.org>
 <20150319075416.GB4568@localhost.localdomain>
 <CAMz4kuKyDFCqd-LfoSKJf+tkXdzzLwtPJdp-nF6NbKU8W5HHpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Stultz <john.stultz@linaro.com>, tglx@linutronix.de,
	Arnd Bergmann <arnd@linaro.org>
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMz4kuKyDFCqd-LfoSKJf+tkXdzzLwtPJdp-nF6NbKU8W5HHpQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 20, 2015 at 09:54:05AM +0800, Baolin Wang wrote:
> Next patch series will contain all of the drivers which need to be changed.
> But i think the conditional in ptp_clock.c can still in there.

Why?

> Because our plan is once all the drivers are converted, i will remove the
> conditional, along with the original function pointer.
> Is that OK? Thanks!

I want to avoid a patch series that introduces something, only to
remove it later on.  Sometimes you have to do that way for a complex
transformation, but this case is rather simple.

You can change the gettime signature in one patch, and the settime in
a second patch.

Thanks,
Richard
