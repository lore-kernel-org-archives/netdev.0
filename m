From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: net-next-2.6 compilation errors: missing wireless/i82593.h
Date: Tue, 17 Nov 2009 12:13:30 +0000
Message-ID: <20091117121330.132ced93@lxorguk.ukuu.org.uk>
References: <4B028A37.1010202@gmail.com>
	<20091117.034428.47467823.davem@davemloft.net>
	<4B029012.6030202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:38782 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756014AbZKQMLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:11:40 -0500
In-Reply-To: <4B029012.6030202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> /home/administer/net-next-2.6/drivers/net/znet.c:107:29: error:
> >> wireless/i82593.h: No such file or directory
> > 
> > That header file got moved out to drivers/staging along with the
> > wavelan driver.
> > 
> Too bad that CONFIG_STAGING "N" (# CONFIG_STAGING is not set) doesn't
> actually turn off all the staging....

It does - that isn't the problem. Someone moves shared header files out
of the right directory into staging without double checking (lxr is
rather handy..)

Alan
