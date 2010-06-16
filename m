From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-06-16 v2
Date: Wed, 16 Jun 2010 14:43:02 -0700 (PDT)
Message-ID: <20100616.144302.28808006.davem@davemloft.net>
References: <20100616182847.GB3138@tuxdriver.com>
	<20100616.115008.226776050.davem@davemloft.net>
	<20100616201300.GD3138@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100616201300.GD3138@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 16 Jun 2010 16:13:00 -0400

> On Wed, Jun 16, 2010 at 11:50:08AM -0700, David Miller wrote:
>> From: "John W. Linville" <linville@tuxdriver.com>
>> Date: Wed, 16 Jun 2010 14:28:48 -0400
>> 
>> > Here is another passel of of fixes intended for 2.6.35.  Included are
>> > some build warning fixes, a PCI identifier, a fix for premature
>> > IRQs during hostap initialization, a fix for a warning caused by
>> > failing to cancel a scan watchdog in iwlwifi, a fix for a null
>> > pointer dereference in iwlwifi, and a fix for a race condition in
>> > the same driver.  Also included is the MAINTAINERS change for the
>> > orphaning of the older Intel wireless drivers.  All but the last few
>> > warning fixes have spent some time in linux-next already.
>> > 
>> > Please let me know if there are problems!
>> 
>> The patches removing unused function variables just to kill compile
>> warnings are not appropriate, _at_ _all_.  They don't fix any real
>> bug, and they definitely don't fix entries in the regression list do
>> they?
>> 
>> Kill all of those and resend this pull request.
> 
> Fair enough...I dropped the warning fixes for the unused variables.
> But I kept the ones related to uninitialized variables, since
> those seem potentially more dangerous to ignore.  Hopefully that
> is acceptable.
> 
> Please let me know if there are problems!

Pulled, thanks!
