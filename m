From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 23:15:52 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003112313540.11569@obet.zrqbmnf.qr>
References: <20100311121239.14944fd5@nehalam> <20100311.122639.258785986.davem@davemloft.net> <20100311140406.37ee0b83@nehalam> <20100311.141325.205780761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:57697 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758415Ab0CKWPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 17:15:53 -0500
In-Reply-To: <20100311.141325.205780761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-03-11 23:13, David Miller wrote:
>
>> That make sense, but maybe we shouldn't send IFLA_STATS64 on
>> 32bit platforms.
>
>Let's at least be optimistic that we'll be able to support 64-bit
>stats on 32-bit at some point :-)

I was about to say. There is hope: whenever you least expect it, 
academia comes up with a perfectly foundated theory and plan to solve 
the problem. (N.B.: But the initial implementation generally sucks ;-)
