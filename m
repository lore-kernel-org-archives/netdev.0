From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth 2015-10-16
Date: Sun, 18 Oct 2015 22:23:55 -0700 (PDT)
Message-ID: <20151018.222355.578335791465873276.davem@davemloft.net>
References: <20151016142900.GA22587@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbJSFHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 01:07:40 -0400
In-Reply-To: <20151016142900.GA22587@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Fri, 16 Oct 2015 17:29:00 +0300

> First of all, sorry for the late set of patches for the 4.3 cycle. We
> just finished an intensive week of testing at the Bluetooth UnPlugFest
> and discovered (and fixed) issues there. Unfortunately a few issues
> affect 4.3-rc5 in a way that they break existing Bluetooth LE mouse and
> keyboard support.
> 
> The regressions result from supporting LE privacy in conjunction with
> scanning for Resolvable Private Addresses before connecting. A feature
> that has been tested heavily (including automated unit tests), but sadly
> some regressions slipped in. The UnPlugFest with its multitude of test
> platforms is a good battle testing ground for uncovering every corner
> case.
> 
> The patches in this pull request focus only on fixing the regressions in
> 4.3-rc5. The patches look a bit larger since we also added comments in
> the critical sections of the fixes to improve clarity.
> 
> I would appreciate if we can get these regression fixes to Linus
> quickly. Please let me know if there are any issues pulling. Thanks.

Ok, pulled, thanks Johan.
