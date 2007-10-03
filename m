From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 03 Oct 2007 14:04:38 -0400
Message-ID: <4703D9B6.109@tmr.com>
References: <1191372129.26233.12.camel@localhost>	 <20071002180209.47c350a3@freepuppy.rosehill> <1191375274.26233.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pomac@vapor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:38382 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757098AbXJCR67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 13:58:59 -0400
In-Reply-To: <1191375274.26233.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Kumlien wrote:
> On tis, 2007-10-02 at 18:02 -0700, Stephen Hemminger wrote:
>> Remove unneeded check that caused problems with jumbo frame sizes.
>> The check was recently added and is wrong.
>> When using jumbo frames the sky2 driver does fragmentation, so
>> rx_data_size is less than mtu.
> 
> Confirmed working.
> 
> Now running with 9k mtu with no errors, =)

Have you verified that you are actually getting jumbo packets out of the 
NIC? I had one machine which did standard packets silently using sky2 
and jumbo using sk98lin. I was looking for something else with tcpdump 
and got one of those WTF moments when I saw all the tiny packets.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
