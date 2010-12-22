From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 22 Dec 2010 08:11:04 +0100
Message-ID: <20101222071104.GA8627@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
 <1292960224.2618.4.camel@work-vm>
 <AANLkTikHV-qN73Zvvvxn76vtFFKG_VNTQhF3qpqTnOrE@mail.gmail.com>
 <1292968784.2618.51.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexander Gordeev <lasaine-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1292968784.2618.51.camel@work-vm>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 01:59:44PM -0800, john stultz wrote:
> However, your concern does bring up a good point: 0x40 is MOD_PPSMAX in
> BSD, and we should at-least check to make sure that the PPS code that is
> currently floating around on the lists and is in akpm's tree hasn't
> already reserved that bit.

If the concern is only about that bit, then we can choose another one
from the range 0x0f00 instead.

It seems to me that the ability to jump the clock is a very useful
feature, at least when implementing a clock servo for PTP in user
space, if not in other cases, too. I wonder why that option is missing
from the interface in the first place.

I am not aware of any serious attempt to get any kind of standardized
PTP clock support into any other OS.  As far as compatibility with NTP
is concerned, why can't we let Linux set an example and let
NTP/BSD/*nix follow us?


Richard
