From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 compilation errors: missing wireless/i82593.h
Date: Tue, 17 Nov 2009 03:44:28 -0800 (PST)
Message-ID: <20091117.034428.47467823.davem@davemloft.net>
References: <4B028A37.1010202@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753741AbZKQLoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 06:44:12 -0500
In-Reply-To: <4B028A37.1010202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Tue, 17 Nov 2009 06:34:15 -0500

> For the past 9-10 days, net-next-2.6 has failed to compile.  In
> addition to the errors and warnings already reported here last week,

Those seemed to be for Android drivers and such, so I hope you
reported those failures to the driver maintainers as well as
linux-kernel.

For the time being could you just disable those drivers in your
build just to get work done or do you absolutely need them?

> since Nov 12th there has been another missing file.  I kept hoping
> it was temporary, but no joy.
> 
> /home/administer/net-next-2.6/drivers/net/znet.c:107:29: error:
> wireless/i82593.h: No such file or directory

That header file got moved out to drivers/staging along with the
wavelan driver.

The header file should instead be moved to, perhaps, include/linux
while there are still other users of it.

That's incredibly clumsy what drivers/net/znet.c is doing.

John please fix this up, thanks!
