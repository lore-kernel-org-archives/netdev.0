From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V7 7/8] ptp: Added a clock driver for the IXP46x.
Date: Sun, 2 Jan 2011 10:12:33 +0100
Message-ID: <20110102091233.GA2847@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <d2e0a5ac5eb51e9e4c7fcc94723b67c72c2f57c1.1292512461.git.richard.cochran@omicron.at>
 <20110102084505.GA3980@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110102084505.GA3980-+ZI9xUNit7I@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 02, 2011 at 09:45:05AM +0100, Pavel Machek wrote:
> Hi!!
> 
> > +struct ixp46x_channel_ctl {
> > +	u32 Ch_Control; /* 0x40 Time Synchronization Channel Control */
> > +	u32 Ch_Event;   /* 0x44 Time Synchronization Channel Event */
> > +	u32 TxSnapLo;   /* 0x48 Transmit Snapshot Low Register */
> > +	u32 TxSnapHi;   /* 0x4C Transmit Snapshot High Register */
> 
> CouldWeGetRidOfCamelCase?

I agree that CamelCase is ugly and in bad taste. However, I make an
exception when the register level programmer's manual uses this style.

IMHO, it is better to use the exact same mnemonics as in the
manual. That way, when the next person comes along to make a change to
the code, with manual in hand, he will immediately know what is what.

Thanks,
Richard
