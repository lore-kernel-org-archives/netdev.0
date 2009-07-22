From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] register at91_ether using platform_driver_probe
Date: Wed, 22 Jul 2009 11:24:56 -0700 (PDT)
Message-ID: <20090722.112456.150910386.davem@davemloft.net>
References: <200907111527.46441.david-b@pacbell.net>
	<1248207099-14583-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<cd73a99e0907221046k5e435fd3m3cb1fd006c0385a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, linux-kernel@vger.kernel.org,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	paulius.zaleckas@teltonika.lt, marc.pignat@hevs.ch,
	linux@maxim.org.za, 12o3l@tiscali.nl, akpm@linux-foundation.org,
	gregkh@suse.de
To: avictor.za@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753386AbZGVSYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 14:24:50 -0400
In-Reply-To: <cd73a99e0907221046k5e435fd3m3cb1fd006c0385a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Victor <avictor.za@gmail.com>
Date: Wed, 22 Jul 2009 19:46:24 +0200

> hi,
> 
>> at91ether_probe lives in .init.text, so using platform_driver_register
>> to register it is wrong because binding a device after the init memory
>> is discarded (e.g. via sysfs) results in an oops.
>>
>> As requested by David Brownell platform_driver_probe is used instead of
>> moving the probe function to .devinit.text as proposed initially.
>> This saves some memory, but devices registered after the driver is
>> probed are not bound (probably there are none) and binding via sysfs
>> isn't possible.
> 
> 
> Acked-by: Andrew Victor <linux@maxim.org.za>

Applied, thanks everyone.
