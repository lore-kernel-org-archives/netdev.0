From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/4] ethtool: don't show sync queue's on skge/sky2
Date: Wed, 27 Sep 2006 19:19:38 -0400
Message-ID: <451B070A.60201@pobox.com>
References: <20060926115437.11ed1f85@freekitty>	<451AF4B1.2000208@pobox.com>	<20060926131000.08a67c89@freekitty>	<451B0345.50504@pobox.com> <20060927153449.695a0f09@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7374 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031242AbWI0XTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:19:40 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060927153449.695a0f09@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 27 Sep 2006 19:03:33 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> Remove printout of synchronous transmit queue info because
>>> it is unused by the driver.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>> NAK, it doesn't matter whether a feature is used by the driver or not.
> 
> Okay, but it's just noise.

It's noise until you notice those registers being used, when you thought 
they were unused... :)  Happens all the time in minor chipset 
variations, for example.

ethtool register dumps should dump __all known__ registers, used or not.

	Jeff



