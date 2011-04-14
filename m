From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Wed, 13 Apr 2011 17:05:03 -0700 (PDT)
Message-ID: <20110413.170503.193709874.davem@davemloft.net>
References: <1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
	<20110413170351.078cfa2f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lkml@scotdoyle.com,
	shimoda.hiroaki@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755179Ab1DNAFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 20:05:39 -0400
In-Reply-To: <20110413170351.078cfa2f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 13 Apr 2011 17:03:51 -0700

> On Wed, 13 Apr 2011 14:48:12 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 13 Apr 2011 17:28:07 +0200
>> 
>> > Dont worry, Stephen or me will send it asap.
>> 
>> I'm looking forward to it :)
> 
> You applied the clear of ipcb already.

There are other patches involved, I think.

The one with the NULL route handling, for one.

Please follow back in this thread for the details, the IPCB clear
wasn't sufficient to get rid of all of the reporter's OOPS's.
