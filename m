From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()
Date: Mon, 08 Apr 2013 12:10:07 -0400 (EDT)
Message-ID: <20130408.121007.2247923729171251811.davem@davemloft.net>
References: <1365195727-24780-1-git-send-email-minipli@googlemail.com>
	<20130405211500.GA14617@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minipli@googlemail.com, samuel@sortiz.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49236 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934447Ab3DHQKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:10:09 -0400
In-Reply-To: <20130405211500.GA14617@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 5 Apr 2013 14:15:00 -0700

> On Fri, Apr 05, 2013 at 11:02:07PM +0200, Mathias Krause wrote:
>> Hi Greg,
>> 
>> I'm unsure if you or Dave should take that one as it's for one a TTY
>> patch but also living under net/. So I'm uncertain and let you decide!
> 
> If Dave want to take it, it's fine with me:
> 
>> -- >8 --
>> Subject: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()
>> 
>> We're clearly running in non-atomic context as our only call site is
>> able to call wait_event_interruptible(). So we're safe to use GFP_KERNEL
>> here instead of GFP_ATOMIC.
>> 
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Applied.
