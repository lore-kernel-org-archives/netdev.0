From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Mon, 21 Apr 2008 13:50:00 +0200
Message-ID: <480C7F68.7090105@trash.net>
References: <20080417103858.0075236b@extreme>	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>	 <480A21AF.1040405@trash.net> <1208692128.12249.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbYDULuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:50:06 -0400
In-Reply-To: <1208692128.12249.26.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Sat, 2008-19-04 at 18:45 +0200, Patrick McHardy wrote:
> 
>> I imagine something like this:
>>
>> # nl-link-dump env eth0
>>
>> LINK_NAME=eth0
>> LINK_IFINDEX=2
>> LINK_LLADDR=.....
>> LINK_OPERSTATE=...
>>
>> and so on. You could then do something like this:
>>
>> export $(nl-link-dump env eth0)
>>
>> and use $LINK_... in your scripts.
>>
> 
> Clever. That would certainly help in portability; i will take a closer
> look on what you did for libnl and see how well it applies for iproute2.

I just noticed the libnl example code already supports this:

$ ./nl-link-dump env dev eth0
LINK_NAME=eth0
LINK_IFINDEX=2
LINK_FAMILY=unspec
LINK_TYPE=ether
...

I wouldn't duplicate it for iproute, but rather complete the
libnl support (I think some object types are still missing
ENV dump format support) and tell people to use that for
scripting.


