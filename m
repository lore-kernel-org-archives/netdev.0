From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG kernel 2.6.25-rc3 IPV6] ping6 -I eth0 ff02::1 causes
 system hang.
Date: Sun, 02 Mar 2008 21:27:17 +0900 (JST)
Message-ID: <20080302.212717.120106718.yoshfuji@linux-ipv6.org>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20080302210716.69727582.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: komurojun-mbn@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53609 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbYCBM0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 07:26:16 -0500
In-Reply-To: <20080302210716.69727582.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to netdev.

In article <20080302210716.69727582.komurojun-mbn@nifty.com> (at Sun, 2 Mar 2008 21:07:16 +0900), Komuro <komurojun-mbn@nifty.com> says:

> On kernel 2.6.25-rc3, IPV6 multicast ping causes system hang
> after sending several multicast ping packet.
> 
> >ping6 -I eth0 ff02::1 
> 
> This problem does not happen on kernel 2.6.24.
> (does not depend on NIC)

Hmm, I've never seen this on our testlab.  Anyone else?
It would be great if you have chance to bisect it...

--yoshfuji
