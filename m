From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Tue, 20 Apr 2010 22:36:59 -0700 (PDT)
Message-ID: <20100420.223659.236667659.davem@davemloft.net>
References: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>
	<20100420.180646.216759318.davem@davemloft.net>
	<A20F7457-20BC-493C-B800-3933D8FC4D5C@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur.tabi@gmail.com, afleming@freescale.com,
	netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751880Ab0DUFhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 01:37:50 -0400
In-Reply-To: <A20F7457-20BC-493C-B800-3933D8FC4D5C@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 20 Apr 2010 23:22:19 -0500

> 
> On Apr 20, 2010, at 8:06 PM, David Miller wrote:
> 
>> From: Timur Tabi <timur.tabi@gmail.com>
>> Date: Tue, 20 Apr 2010 10:01:48 -0500
>> 
>>> On Mon, Apr 19, 2010 at 11:43 PM, Kumar Gala <galak@kernel.crashing.org> wrote:
>>> 
>>>> spin_event_timeout doesn't make sense for this.  The patch is fine.
>>> 
>>> Can you please elaborate on that?  I don't understand why you think
>>> that.  spin_event_timeout() takes an expression and a timeout, and
>>> loops over the expression calling cpu_relax(), just like this loop
>>> does.
>> 
>> Indeed it does, Kumar this request seems reasonable.
> 
> Are we saying that cpu_relax() is useless and should be removed if we are spinning on a HW register?

Kumar, take a deep breath and a step back.

spin_event_timeout() does the cpu_relax() too, that's what Timur is
trying to tell you.

The code will be basically identical as far as I can tell.
