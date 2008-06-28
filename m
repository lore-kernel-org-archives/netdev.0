From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] RTT metrics scaling
Date: Sat, 28 Jun 2008 01:07:36 -0700 (PDT)
Message-ID: <20080628.010736.171730473.davem@davemloft.net>
References: <20080620162234.1c2103ee@extreme>
	<20080627.195013.184418536.davem@davemloft.net>
	<20080627223007.02eb6622@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbYF1IHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2008 04:07:37 -0400
In-Reply-To: <20080627223007.02eb6622@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 27 Jun 2008 22:30:07 -0700

> On Fri, 27 Jun 2008 19:50:13 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > But aren't we approaching microsecond RTT's soon? :-) (yes, I know in
> > TCP we min clamp at 200ms RTT, but that clamp we probably want to
> > remove soon)
>
> We could put in microseconds, but since it is computer off of
> jiffies (ie clock ticks), the resolution wouldn't be worth it.

Fair enough.

> 
> > If you don't think that's worth worrying about, I'll apply this patch.
> 
> Hold off it needs more testing.

Ok.
