From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 15:10:50 -0800
Message-ID: <20100311151050.31f8ad5d@nehalam>
References: <20100311140406.37ee0b83@nehalam>
	<alpine.LSU.2.01.1003112305060.11569@obet.zrqbmnf.qr>
	<20100311145059.1a020e1c@nehalam>
	<20100311.145412.118613343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59370 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641Ab0CKXK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 18:10:58 -0500
In-Reply-To: <20100311.145412.118613343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Mar 2010 14:54:12 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 11 Mar 2010 14:50:59 -0800
> 
> > But if you send 32bit truncated values when 64 bit is expected
> > then users are going to complain
> 
> They already complain, a lot.
> 
> This isn't going to change the situation at all, and
> I agree with Jan that consistency is the trumping factor
> here.

But if non utilities will already adapt to new/old kernel, so
just don't put out 64 bit values if the platform is 32 bit.
When/if 32 bit platforms support it, great add the extra stats.

-- 
