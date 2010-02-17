From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [net-next PATCH] via-velocity: Enable scatter/gather IO by
 default
Date: Wed, 17 Feb 2010 07:19:44 +0100
Message-ID: <20100217071944.14183e50@marrow.netinsight.se>
References: <20100211163955.1b1dbe2c@marrow.netinsight.se>
	<20100216.162015.77292959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:22583 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751249Ab0BQGTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 01:19:54 -0500
In-Reply-To: <20100216.162015.77292959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Feb 2010 16:20:15 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> > Reduces CPU utilization significantly with sendfile for example.
> > 
> > Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
> 
> I think you need to have a look at this patch before making
> a change like this:
> 
> commit 83c98a8cd04dd0f848574370594886ba3bf56750
> Author: Dave Jones <davej@redhat.com>
> Date:   Tue Jul 21 09:15:49 2009 +0000
> 
>     Remove unused zero-copy code from velocity NIC driver.
>     
>     This code hasn't been enabled in forever.

Well I reenabled it here:

  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=c79992fddee28bbd31b35ac297e1068d32930179

it was also cleaned up to remove all the #ifdefs around that code.

// Simon
