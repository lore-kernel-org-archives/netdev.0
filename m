From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Keep kernel coding style rule of hfs-s+/sp source
Date: Thu, 02 Feb 2012 11:11:59 -0800
Message-ID: <1328209919.18641.42.camel@joe2Laptop>
References: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
	 <20120201.020602.131240058939599710.davem@davemloft.net>
	 <CAGFP0LKU0uDPQzhCy8qmThXQ9f9ofSnQrbr2dO83i+usc85_FQ@mail.gmail.com>
	 <20120201.024843.318636456202840126.davem@davemloft.net>
	 <20120202190152.GB11660@gw.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: geunsik.lim@gmail.com, David Miller <davem@davemloft.net>,
	isdn@linux-pingi.de, lucas.demarchi@profusion.mobi,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120202190152.GB11660@gw.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-02 at 20:01 +0100, Karsten Keil wrote:
> > >> This was probably there to eliminate compiler warnings or avoid the
> Yes it was.
[]
> I think in this case a coding style violation is minor to a warning or
> potencial miscompiling.
> Do not misunderstand me that I do not like to make the code better and more
> readable, but such small style violations should be only fixed when here is
> a strong need or the driver is reworked in bigger parts and full testing
> is done.

I agree, but in the future (or perhaps even today)
it's better to mark these odd coding style uses with
macros to indicate the reason for their use.

Perhaps something akin to the ACCESS_ONCE macro like

#define PERFORM_ONCE(expr)		\
do {					\
	if ((expr))			\
		;			\
} while (0)
