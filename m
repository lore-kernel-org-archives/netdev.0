From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Fri, 04 Mar 2016 16:24:19 +0100
Message-ID: <1659125.tHp8H942OG@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de> <1456945629-1793533-2-git-send-email-arnd@arndb.de> <56D7F62E.6050502@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: isdn@linux-pingi.de,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56D7F62E.6050502@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 March 2016 09:30:38 isdn@linux-pingi.de wrote:
> Hi Arnd,
> I fully agree and ack.
> Thanks for the work.
> 

I actually did more patches that I ended up not submitting:

* move hisax to staging
* remove i4l support from gigaset
* move i4l core to staging

while I initially thought that i4l as a whole is not just unmaintained
but also more or less unused, patch 19cebbcb04c8 ("isdn: Partially
revert debug format string usage clean up") came in that indicated that
there are still users that even send patches for hisax, and that
made me doubt whether we could consider it obsolete enough.

Any thoughts on this? If you like, I can send those too.

My main motivation was to not have to fix up the ippp implementation
when I move the compat ioctl handler from fs/compat_ioctl.c
into drivers/net/ppp/ppp_generic.c, but I guess I can do that
anyway as it seems that i4l never worked properly in compat mode.

	Arnd
