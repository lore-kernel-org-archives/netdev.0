From: Arnd Bergmann <arnd@linaro.org>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces with "ktime_t" type
Date: Sun, 22 Mar 2015 03:47:06 +0100
Message-ID: <201503220347.06550.arnd@linaro.org>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org> <201503210216.41497.arnd@linaro.org> <20150321072407.GA4701@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150321072407.GA4701@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 21 March 2015, Richard Cochran wrote:
> On Sat, Mar 21, 2015 at 02:16:41AM +0100, Arnd Bergmann wrote:
> > This was the first idea, but it seems a bit silly when all the drivers
> > use a 64-bit nanosecond value just like ktime_t.
> 
> Not true of all drivers.  In fact, the most capable devices (phyter
> and i210) have a split representation.

Ok, sorry for missing those earlier, I thought I'd looked at all 
of them and not found any that did it like this.

> > but it is not any more
> > or less efficient than the previous method.
> 
> Right, so no point in changing it.
> 
> > Of course, but it would be rather bad style.
> 
> Introducing useless code just to remove it again is also bad style.
> 
> I disagree with the approach presented here.  The problem at hand is
> the 2038 issue.  Let's fix that first, in the easiest way, with the
> least churn, namely by using timespec64 in place of timespec.  Once
> that is done, we can change over to ktime_t, if and when the need
> arises.

Ok, fair enough. I only saw this mail now after replying on the
longer series, consider my comment on ktime_t withdrawn.

	Arnd
