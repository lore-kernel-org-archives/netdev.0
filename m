From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/21] ARCNET: Defibrillation
Date: Fri, 24 Apr 2015 23:58:53 -0400 (EDT)
Message-ID: <20150424.235853.1997287895150693202.davem@davemloft.net>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	<1429901273.23327.5.camel@perches.com>
	<553AB241.3080004@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, m.grzeschik@pengutronix.de,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-kernel@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035AbbDYD65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 23:58:57 -0400
In-Reply-To: <553AB241.3080004@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 24 Apr 2015 23:14:41 +0200

> On 04/24/2015 08:47 PM, Joe Perches wrote:
>> On Fri, 2015-04-24 at 19:20 +0200, Michael Grzeschik wrote:
>>> Hi!
>> 
>> Hello.
>> 
>>> This patch series tries to reanimate the ARCNET hardware layer to be
>>> somehow readable and maintainable again. It includes a lot of cleanup
>>> patches. It also adds some fixes which leads the layer to become usable
>>> again. And as a special treatment it adds more features like correct
>>> loading and unloading of the com20020 card.
>> 
>> Wow.  Good for you, but why?  Does anyone still use these?
> 
> Yes, there are parts of the industry where "old" machines are
> retrofitted with new hardware...and a lot of these machines still talk
> ARCNET :)

But the real issue is, this layer is development wise in the same
category as the IDE layer.

Any non-trivial change is nothing but pure risk, especially given the
low level of test coverage the code gets.

So I really only want to see the most critical obvious bug fixes
submitted for this layer and drivers.

And no I will not accept an argument stating that you have to
restructure and clean this code up in order to fix the bugs.  That's
bogus.

I'm rejecting this patch series, sorry.
