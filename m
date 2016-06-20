From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Sun, 19 Jun 2016 20:07:41 -0700 (PDT)
Message-ID: <20160619.200741.1114304127682357737.davem@davemloft.net>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<20160617.200947.2078656051211641868.davem@davemloft.net>
	<CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbcFTDPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 23:15:24 -0400
In-Reply-To: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 17 Jun 2016 20:52:55 -0700

> For instance, TFO was put in the Linux several years ago, but it
> still hasn't been enabled in Android and only fairly recently
> enabled in iOS.

"Android decided to get locked into a really old kernel for 6+ years"
is not really a good argument, sorry.

We've already been hurt badly by the poor decisions the Android folks
have made wrt. the handling of their kernel.

Let's not make it worse by also making userland TCP stacks ubiquitous
as a side effect.

I've been assured several times that the Android situation will at
the very least improve.

And if it does improve and features do propagate more quickly, we'll
have all of this risk and gambling unnecessarily.

Let's not route around the Android problem, but rather get them to
address it properly.
