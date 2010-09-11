From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Change addrconf code to deal with link changes
 better
Date: Fri, 10 Sep 2010 21:10:29 -0400
Message-ID: <4C8AD705.10200@hp.com>
References: <4C8A9BF7.2090102@hp.com> <40oql7-6f5.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:33003 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab0IKBKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 21:10:33 -0400
In-Reply-To: <40oql7-6f5.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2010 06:27 PM, Alexander Clouter wrote:
> Brian Haley <brian.haley@hp.com> wrote:
>>
>> [snipped]
>>
>> Change the IPv6 addrconf code to handle the case where the NIC link
>> state goes UP-DOWN-UP by removing all the autoconfigured addresses
>> when it goes down, so that when it comes back up they will get added
>> again and DAD will be triggered.  
>>
> Surely this is going to result in me sending you lots of rude emails 
> everytime cursing you when my SSH connections are terminated for no real 
> reason on a link flap?  Privacy addresses are handy on servers too such 
> as DNS servers...

No, you'd be sending me some rude emails, I didn't test that particular
case, so Dave, don't apply this.  I guess we've lived with it long enough
the way it is that dropping a few packets at initialization isn't *that*
bad.  I'll see if I can figure out a better way in the meantime...

-Brian
