From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skbuff bug?
Date: Tue, 26 Aug 2008 13:17:53 +0400
Message-ID: <20080826091752.GB5822@2ka.mipt.ru>
References: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com> <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	Ingo Molnar <mingo@elte.hu>,
	Bruce Allan <bruce.w.allan@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:40476 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbYHZJT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 05:19:29 -0400
Content-Disposition: inline
In-Reply-To: <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Aug 21, 2008 at 04:46:49PM -0700, Yinghai Lu (yhlu.kernel@gmail.com) wrote:
> it seems caused by
> 
> commit f8d59f7826aa73c5e7682fbed6db38020635d466
> Author: Bruce Allan <bruce.w.allan@intel.com>
> Date:   Fri Aug 8 18:36:11 2008 -0700
> 
>     e1000e: test for unusable MSI support

Intel folks seems to be on vacations or whatever else without access to
the mail. Can you confirm that bug still exists in the latest tree and
reverting this commit fixes the problem?

-- 
	Evgeniy Polyakov
