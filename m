From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V9 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Thu, 13 Jan 2011 12:57:08 -0800
Message-ID: <1294952228.5617.20.camel@work-vm>
References: <cover.1294917347.git.richard.cochran@omicron.at>
	 <60566a54842bcf5974d55ed39f387c32ff9cf5cb.1294917348.git.richard.cochran@omicron.at>
	 <AANLkTimHP1OsWauj6O566WgnxVTjMbNg2PK644QcT9Lq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimHP1OsWauj6O566WgnxVTjMbNg2PK644QcT9Lq-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-14 at 05:39 +0900, Kuwahara,T. wrote:
> My proposal: Limit the adjustable range of the offset so that leap
> seconds will never occur more than once. (2147.5 seconds would be the
> best choice. :-)

2147.5? That's ~36 minutes. 

While I think a limit could be a sensible compromise here. Leap seconds
are limited to every six months. So surely a limit of 86400 (one day),
or 2592000 (30 days) would be more reasonable.

thanks
-john
