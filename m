From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch v2] fix stack overflow in pktgen_if_write()
Date: Thu, 28 Oct 2010 08:05:00 +0200
Message-ID: <20101028060500.GW6062@bicker>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com> <20101027221234.GN6062@bicker> <20101027224302.GQ6062@bicker> <20101027230657.GT16803@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	netdev@vger.kernel.org
To: Nelson Elhage <nelhage@ksplice.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33306 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab0J1GFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 02:05:13 -0400
Received: by wyf28 with SMTP id 28so1546696wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 23:05:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101027230657.GT16803@ksplice.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 07:06:57PM -0400, Nelson Elhage wrote:
> You want to add a trailing NUL, or else printk will read off the end of the
> buffer.
> 
> Also, by memdup()ing count + 1 bytes, you're technically reading one more byte
> than userspace asked for, which could in principle lead to a spurious EFAULT.
> 

That's a lot of bugs per line.  :(  I'm eating humble pie today...

regards,
dan carpenter


