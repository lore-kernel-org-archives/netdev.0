From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Thu, 25 Jul 2013 21:31:22 +0300
Message-ID: <CAHp75VeqgqVdn+zRjW+McwFQfD73NhYz4X3M4ndeDZnkFmqyEg@mail.gmail.com>
References: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
	<51F07489.7010404@gmail.com>
	<CAD6i1fJO3geZ0vkHLsJEd+KedHkpC1OZVTJJskU2RAAKYBhhJQ@mail.gmail.com>
	<CAD6i1f+NYu7rcQwF-TXk4+OdjPNZwMKxxjJ9YA_+v9B6uPYq+g@mail.gmail.com>
	<CAHp75VdouA2w5WjBPJ2cX8AKvTeCNrj6pM+3SS5DzU+ARM5M3Q@mail.gmail.com>
	<CAP8WD_aKqqB4Fb4Vadj_AJ4ET5gxd+EkaCMMVvBxxqNwDjpBGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Prashant Shah <pshah.mumbai@gmail.com>,
	Ryan Mallon <rmallon@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	mwhitehe@redhat.com, kernel-mentors@selenic.com
To: whiteheadm@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:42232 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab3GYSbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:31:23 -0400
In-Reply-To: <CAP8WD_aKqqB4Fb4Vadj_AJ4ET5gxd+EkaCMMVvBxxqNwDjpBGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 6:20 PM, tedheadster <tedheadster@gmail.com> wrote:
> Andy,
>   I can't find a single example of a devres_* call in
> drivers/net/ethernet/*. Does any networking code exist that we can look at
> as an example for conversion to the devres API?

devres API usually means managed version of the functions that used
mostly at probe() stage.
For example, devm_*() or pcim_*() calls.

-- 
With Best Regards,
Andy Shevchenko
