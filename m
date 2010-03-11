From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 15:44:56 -0800
Message-ID: <20100311154456.24bde0ac@nehalam>
References: <20100311145059.1a020e1c@nehalam>
	<20100311.145412.118613343.davem@davemloft.net>
	<20100311151050.31f8ad5d@nehalam>
	<20100311.151529.16498686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60827 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab0CKXpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 18:45:01 -0500
In-Reply-To: <20100311.151529.16498686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 15:15:29 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 11 Mar 2010 15:10:50 -0800
> 
> > But if non utilities will already adapt to new/old kernel, so
> > just don't put out 64 bit values if the platform is 32 bit.
> > When/if 32 bit platforms support it, great add the extra stats.
> 
> How about we just make userland ready for it and:
> 
> 1) Emitting it now will get it tested even on 32-bit
> 
> 2) They'll be ready when the drivers can keep track of
>    64-bit stats too.
> 
> Stephen I've heard your side of the story, I just don't
> agree with it :-)

I'm okay with it. just raising the issue.

-- 
