From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sat, 19 May 2012 13:30:38 +0100
Message-ID: <20120519133038.282d0a7d@bob.linux.org.uk>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
	<201205182016.51489.linux@rainbow-software.org>
	<20120518220305.GC15256@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ondrej Zary <linux@rainbow-software.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43104 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab2ESMPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2012 08:15:15 -0400
In-Reply-To: <20120518220305.GC15256@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You miss the point.  We've got someone with a modern i7 machine who is
> getting confused by seeing messages from some ancient 3c501 driver,
> but he doesn't have the context to know it is ancient and the message
> is a red herring.  Will it fix a distro's broken init that tries to
> modprobe everything?  No.  Will it help by not muddying the waters
> with meaningless printk from 3c501 that confuse users?  Yes.

That seems a totally bogus reason for removing stuff. The kernel cannot
manage every possible distribution and user screw up. They have more
variety so they will always win the battle.

Removing it because nobody is running one even in a museum might be a
good reason, but then the driver still works fine.

Also btw: the 3c501 isn't all TTL it's integrated. The 3c500 is all TTL
and an amazing beast, its so big it won't fit a 16bit slot as it has to
drop down after the connector to get all the chips on.

(and yes I have a 3c500)

However I don't think this is the right way to tackle the ethernet
history situation. As with MCA we should pull *all* the real historical
interest only bits in one go so it's immediately obvious where the
break point is for all devices.

That or we'll replace confused distros and uses with confused ancient
machine owners, and the latter can be far more persistent and
irritating ;)

So should we dump ISA ?

Alan
