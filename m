From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 17:39:46 -0700
Message-ID: <20080328173946.23903be0.akpm@linux-foundation.org>
References: <20080328165437.bfd7726c.akpm@linux-foundation.org>
	<20080328.165812.253071507.davem@davemloft.net>
	<20080328171128.ff03ec02.akpm@linux-foundation.org>
	<20080328.173523.66723417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56728 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754333AbYC2AkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:40:13 -0400
In-Reply-To: <20080328.173523.66723417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 17:35:23 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Fri, 28 Mar 2008 17:11:28 -0700
> 
> > Plus uninitialized_var() gives us something to grep for and
> > experiment with if/when future gcc's get smarter.
> 
> That's sounds like a great investment of your time.
> 
> I guess there aren't any more interesting things to work
> on, nor bugs to fix.

So you're all outa reasons.

I have explained our reasons for using uninitialized_var() rather than
sprinkling =0 all over the place, that's all.

