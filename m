From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Tue, 29 Mar 2016 17:03:48 -0400 (EDT)
Message-ID: <20160329.170348.883731618823989561.davem@davemloft.net>
References: <CALx6S37xUjQpxYdskm0Lt33MQr6Jwwg1eGjZYnadX8762EuxBg@mail.gmail.com>
	<CAMt9YRo07TD0kxkdKve2kD_E=xt89Cf=08=ZzZ_j+k1=6R5R-g@mail.gmail.com>
	<CALx6S37GPMUuhgiWRH+40314x8eKnCWA-zZkvUmsTqf3_AFOhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, alexander.duyck@gmail.com, jesse@kernel.org,
	netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758149AbcC2VDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 17:03:51 -0400
In-Reply-To: <CALx6S37GPMUuhgiWRH+40314x8eKnCWA-zZkvUmsTqf3_AFOhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 28 Mar 2016 21:51:17 -0700

> No, but I do expect that you support code that is already there. There
> was apparently zero testing done on the original patch and it caused
> one very obvious regression. So how can we have any confidence
> whatsoever that this patch doesn't break other things? Furthermore,
> with all these claims of bugs I still don't see that _anyone_ has
> taken the time to reproduce any issue and show that this patch
> materially fixes any thing. I seriously don't understand how basic
> testing could be such a challenge.
> 
> Anyway, what I expect is moot. It's up to davem to decide what to do
> with this...

You being upset with a lack of testing is one issue, and is
legitimate.

But the fact that we can't support, and never could support, more than
one network header at a time except in a very special case for GRO
is very real.  And you must acknowledge that this was a very shaky
foundation upon which to erect the kinds of things you expect to work.
