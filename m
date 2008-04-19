From: Patrick McHardy <kaber@trash.net>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Sat, 19 Apr 2008 18:45:35 +0200
Message-ID: <480A21AF.1040405@trash.net>
References: <20080417103858.0075236b@extreme>	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55471 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195AbYDSQt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 12:49:27 -0400
In-Reply-To: <1208563696.4450.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Fri, 2008-18-04 at 16:22 +0200, Patrick McHardy wrote:
>
>   
>> Yes, that sucks (ran into the same problem with iproute in a
>> previous job). I added the ENV dump format to libnl a couple
>> of years ago (NAME=val), should be easy to add a set of simple
>> tools to get the information and export it in the environment.
>>     
>
> Can you explain this a little? Would these variables define what
> the command line parameters look like before invoking?

I imagine something like this:

# nl-link-dump env eth0

LINK_NAME=eth0
LINK_IFINDEX=2
LINK_LLADDR=.....
LINK_OPERSTATE=...

and so on. You could then do something like this:

export $(nl-link-dump env eth0)

and use $LINK_... in your scripts.

