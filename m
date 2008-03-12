From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netconsole still hangs
Date: Wed, 12 Mar 2008 16:16:37 -0700
Message-ID: <20080312161637.b082b515.akpm@linux-foundation.org>
References: <20080312161429.d5b1c67b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59079 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754377AbYCLXRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 19:17:10 -0400
In-Reply-To: <20080312161429.d5b1c67b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 16:14:29 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> I thought the recent reverts fixed this, but it seems that it's just become
> a little harder to hit.
> 
> I'm seeing netconsole hangs on two x86_64 systems (2-way t61p laptop, 8-way
> server).  Both use e1000.
> 
> With current mainline on the 8-way, create a printk storm with
> 
> while true
> do
> 	echo t > /proc/sysrq-trigger
> done
> 
> and the machine goes tits-up after about five seconds.
> 

whoops, hang on, it's still running.  For some reason the receiving machine
went super-slow after it had received a lot of data.

I'll retest on the t61p this evening, see why it is freezing.
