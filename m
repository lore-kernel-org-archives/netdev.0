From: David Miller <davem@davemloft.net>
Subject: Re: [BUG kernel 2.6.25-rc3 IPV6] ping6 -I eth0 ff02::1 causes
 system hang.
Date: Sat, 08 Mar 2008 03:56:47 -0800 (PST)
Message-ID: <20080308.035647.193709286.davem@davemloft.net>
References: <20071014073658.d4352b8c.komurojun@nifty.com>
	<20080302210716.69727582.komurojun-mbn@nifty.com>
	<20080308134410.69d07a2d.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: komurojun-mbn@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49561
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752833AbYCHL4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 06:56:46 -0500
In-Reply-To: <20080308134410.69d07a2d.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Komuro <komurojun-mbn@nifty.com>
Date: Sat, 8 Mar 2008 13:44:10 +0900

> The bad commit is below.
> 
> 69cc64d8d92bf852f933e90c888dfff083bd4fc9 is first bad commit
> commit 69cc64d8d92bf852f933e90c888dfff083bd4fc9
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Feb 11 21:45:44 2008 -0800
> 
>     [NDISC]: Fix race in generic address resolution
> 
>     Frank Blaschka provided the bug report and the initial suggested fix
>     for this bug.  He also validated this version of this fix.

This was a known bad commit and got reverted more than a week ago.
