From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 18 Jul 2006 22:46:12 +0100
Message-ID: <44BD56A4.9090002@andyfurniss.entadsl.com>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <1151158431.6716.95.camel@jzny2> <1153188409.13145.5.camel@ras.pc.brisbane.lube>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:46515 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S932089AbWGRVpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 17:45:21 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1153188409.13145.5.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Sat, 2006-06-24 at 10:13 -0400, jamal wrote:
> 
>>And yes, I was arguing that the tc scheme you describe would not be so
>>bad either if the cost of making a generic change is expensive.
> 
> <snip>
> 
>>Patrick seems to have a simple way to compensate generically for link
>>layer fragmentation, so i will not argue the practically; hopefully that
>>settles it? ;->
> 
> 
> Things seem to have died down.  Patrick's patch seemed 
> unrelated to ATM to me.  I did put up another suggestion, 
> but I don't think anybody was too impressed with the 
> idea.  So that leave the current ATM patch as the only 
> one we have on the table that addresses the ATM issue.

FWIW I think it may be possible to do it Patricks' way, as if I read it 
properly he will end up with the ATM cell train length which gets 
shifted by cell_log and looked up as before. The ATM length will be in 
steps of 53 so with cell_log 3 or 4 I think there will be no collisions 
- so special rate tables for ATM can still be made perfect.

As you say, I think mpu should be added aswell - so eth/other can benefit.


Andy.
