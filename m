From: Roland Stigge <stigge@antcom.de>
Subject: Re: r8169 delay / segfault
Date: Thu, 18 Oct 2012 23:06:10 +0200
Message-ID: <50806F42.9070505@antcom.de>
References: <50787109.7080605@antcom.de> <20121012210503.GA2054@electric-eye.fr.zoreil.com> <50789649.3080202@antcom.de> <50793B6F.50507@antcom.de> <20121014213224.GA23396@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:41619 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754157Ab2JRVGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 17:06:41 -0400
In-Reply-To: <20121014213224.GA23396@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/10/12 23:32, Francois Romieu wrote:
>> How can we force the device out of D3 power state?
>>
>> I also compared with kernel 3.5, and it seems like a regression to me,
>> With 3.5, it works and tells on resume:
> 
> Can you try both a 3.5 kernel with the 3.6 r8169 driver and a 3.6 kernel
> with the 3.5 r8169 driver ?

Sorry for the delay.

What makes the whole thing difficult is that on vanilla 3.6, the problem
happens always, while with vanilla 3.5 it also happens but much less
often - about every 10th suspend / resume cycle.

To test the 3.5 r8169 driver with a 3.6 kernel, and vice versa, I copied
over the r8169.c file, respectively.

The result is that the 3.6 kernel with the "old" driver shows the same
issue as the vanilla 3.6. On 3.5 I also see the same thing happen as
before - every 10th suspend / resume cycle the problem happens,
independent of the "old" or "new" driver.

So the difference comes from the kernel, but finally it is present
anyway. Maybe it is just triggered more efficiently in 3.6? ;-)

Remember that I don't encountered problems with other drivers'
suspend/resume, only with the r8169.

Thanks for considering. Please tell me how I can help further on this issue.

Roland
