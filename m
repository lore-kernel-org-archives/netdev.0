From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Mon, 17 May 2010 23:06:13 -0700 (PDT)
Message-ID: <20100517.230613.84405207.davem@davemloft.net>
References: <1273767626.6117.3.camel@bigi>
	<20100513092643.6551cb48@nehalam>
	<1273768808.6117.5.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752881Ab0ERGGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 02:06:04 -0400
In-Reply-To: <1273768808.6117.5.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Thu, 13 May 2010 12:40:08 -0400

> On Thu, 2010-05-13 at 09:26 -0700, Stephen Hemminger wrote:
> 
>> > 
>> 
>> And the kernel message needs to be fixed to prevent total
>> log overload for the next poor sop who makes the same mistake.
>> 
>> Please accept the patch.
> 
> I have no problem with the patch. Dont think it needs to go to stable
> but i'll let Dave call it.
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, I don't think it's -stable material personally.  If we start
queueing stuff like this, it will be 200 instead of 100 patches in
each -stable release :-)
