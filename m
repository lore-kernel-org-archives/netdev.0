From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [TSN RFC v2 0/9] TSN driver for the kernel
Date: Sat, 17 Dec 2016 21:09:34 +0100
Message-ID: <20161217200934.GA4797@localhost.localdomain>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
 <20161216220530.GA25258@netboy>
 <20161217090554.GA19737@icarus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Henrik Austad <haustad@cisco.com>,
        linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: Henrik Austad <henrik@austad.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161217090554.GA19737@icarus.home.austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 10:05:54AM +0100, Henrik Austad wrote:
> I'm sending out a new set now because, what I have works _fairly_ well for 
> testing and a way to see what you can do with AVB. Using spotify to play 
> music on random machines is quite entertaining.

You have missed the point about TSN entirely.  Unless your demo has
synchronized playback (in the low microsecond range), then it really
is pointless.  We can already play music over the LAN using gstreamer,
without a single kernel change.  Heck, gstreamer even has its own
rudimentary synchronization, so your series is a step backwards.

> And therein lies the problem. It cannot yet be written, so we have to start 
> in *some* end. And as I repeatedly stated in June, I'm at an RFC here, 
> trying to spark some interest and lure other developers in :)

The best way to attract interest is to provide the critical
infrastructure missing in the kernel.  Coding a media player in kernel
space is not very interesting in my view.

> Yes, and this requires a lot of change to ALSA (and probably something in 
> V4L2 as well?), so before we get to that, perhaps have a set of patches 
> that does this best effort and *then* work on getting time-triggered 
> playback into the kernel?

No, we don't need a best effort implementation.  That is gstreamer and Co.

> So, the next issue I plan to tackle, is how I do buffers, the current 
> approach where tsn_core allocates memory is on its way out and I'll let the 
> shim (which means alsa/v4l2) will provide a buffer. Then I'll start looking 
> at qdisc.

More than once you wrote something like, "I know that's needed, but it
is just too hard ATM."  Please start with qdisc and tc.  That
shouldn't be too hard.  If we had the AVB shaping rules with one or
two drivers supporting them, that would be one piece already done.

Thanks,
Richard
