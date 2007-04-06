From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 15:01:46 -0700
Message-ID: <4616C34A.4020503@candelatech.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>	<20070406133420.2f098bc6@localhost>	<4616BDEA.1080502@candelatech.com> <20070406135447.112c182c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32824 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933174AbXDFWCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 18:02:30 -0400
In-Reply-To: <20070406135447.112c182c@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 06 Apr 2007 14:38:50 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>
>   
>> Stephen Hemminger wrote:
>>     
>>> Why not implement a true virtual network rather than simple
>>> tunnel pairs?
>>>   
>>>       
>> What would a true virtual network do?  You mean with routers and such?
>>     
>
> Rather than just a pair, you could do address matching of destination
> address.
>   
At layer-2, you can already do this by adding the etun device to a 
bridge and let the bridge
do the work.

At layer-3, you can use the routing tables...and all of the other clever 
logic of the linux
kernel.

Imagine what you could do if you had 2000 ethernet ports on your machine 
and lots of
loop-back cables..that is essentially what etun gives you...

Lord knows I love writing virtual devices..but it always seems to turn 
out best if you
leave each piece simple and use the normal linux tools and features to 
put the simple
features together into something much more powerful.

Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


