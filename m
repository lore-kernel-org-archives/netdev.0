From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] posix clocks: introduce a sysfs presence.
Date: Fri, 10 Sep 2010 11:31:35 +0200
Message-ID: <20100910093135.GB10179@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <84124d2479b8967cac2b35f852fc0fcae6ad9444.1283504065.git.richard.cochran@omicron.at>
 <20100910000008.1483fdd7@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100910000008.1483fdd7-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 10, 2010 at 12:00:08AM +0100, Alan Cox wrote:
> Also we have existing time sources that don't follow the poxix clock
> model - I can open /dev/rtc and I can open the hpet and so on.
> 
> I like /sys/class/time* *but* you need to be able to open the sysfs
> device and apply operations to it in order for it to work when your closk
> can be dynamically created and destroyed and to get a sane Unix API.
> 
> To start with try applying permissions to clock sources via the POSIX
> API. That is something that will be required for some applications.
> 
> I need to be able to open sys/clock/foo/something and get a meaningful
> handle. Sure it's quite likely the operations it supports are related to
> the POSIX timer ops.

Do you mean this:

   id = read(/sys/clock/foo/lock); /* clock is busy, cannot be removed */
   ...
   clock_gettime(id, ts);
   ...
   write(/sys/clock/foo/release, id); /* all done with clock */

I am not sure what you are describing. Can you give an example, like
pseudocode or something?

Thanks,
Richard
