From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH] Keep kernel coding style rule of hfs-s+/sp source
Date: Thu, 2 Feb 2012 20:01:52 +0100
Message-ID: <20120202190152.GB11660@gw.linux-pingi.de>
References: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
 <20120201.020602.131240058939599710.davem@davemloft.net>
 <CAGFP0LKU0uDPQzhCy8qmThXQ9f9ofSnQrbr2dO83i+usc85_FQ@mail.gmail.com>
 <20120201.024843.318636456202840126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, isdn@linux-pingi.de,
	lucas.demarchi@profusion.mobi, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geunsik.lim@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120201.024843.318636456202840126.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 02:48:43AM -0500, David Miller wrote:
> From: Geunsik Lim <geunsik.lim@gmail.com>
> Date: Wed, 1 Feb 2012 16:45:09 +0900
> 
> > On Wed, Feb 1, 2012 at 4:06 PM, David Miller <davem@davemloft.net> wrote:
> > 
> >> From: Geunsik Lim <geunsik.lim@gmail.com>
> >> Date: Wed,  1 Feb 2012 15:59:53 +0900
> >>
> >> > Modified for kernel coding style rule of hfs-s+/sp device driver .
> >> > . reference: ./Documentation/CodingStyle
> >> >
> >> > ex)
> >> > 60 Don't put multiple statements on a single line unless you have
> >> > 61 something to hide:
> >> > 62
> >> > 63         if (condition) do_this;
> >> > 64           do_something_everytime;
> >> >
> >> > Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
> >>
> >> This was probably there to eliminate compiler warnings or avoid the

Yes it was.

> >>
> > Thank you for your opinion.
> > It's strange. I did not meet compiler warnings you replied.

I did not remember which version it was, it must been arround the time
when that code was developed. I did not like this method, but this was
at this time the suggested workaround from the GCC guys the problem is,
even when you read the value into a register, it makes no difference, you
cannot do anything with it.
I agree with David, such patches are not really needed, the danger that
something gets wrong is too high.
I think in this case a coding style violation is minor to a warning or
potencial miscompiling.
Do not misunderstand me that I do not like to make the code better and more
readable, but such small style violations should be only fixed when here is
a strong need or the driver is reworked in bigger parts and full testing
is done.

Best Regards

Karsten
