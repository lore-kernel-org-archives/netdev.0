From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Thu, 29 May 2008 07:34:25 -0500
Message-ID: <483EA2D1.8050603@sngx.net>
References: <482DA5B6.1020606@sngx.net>	<482DB46A.8020103@cosmosbay.com>	<482EF192.4070707@sngx.net>	<482F5113.5090703@cosmosbay.com>	<482F610D.2080108@sngx.net>	<20080518003104.GK28241@solarflare.com>	<482FBA09.80201@sngx.net>	<483E0AAE.2020107@sngx.net> <20080528221118.63da4092.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754587AbYE2MdU@vger.kernel.org>
In-Reply-To: <20080528221118.63da4092.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You didn't provide a reason from adding this feature to the kernel.

Sorry, my reasoning was in my original patch only.  The ability to reset network 
counters is, in my experience, one of the first things you do when trying to 
troubleshoot networking issues - especially when you have incrementing errors.


> Many of the kernel's accounting accumulators cannot be reset.  We
> handle that in userspace tools by using subtraction.

I don't think that should preclude the ability to reset these, unless it is
shown that it would break something very badly.
