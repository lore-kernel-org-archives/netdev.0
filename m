From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: [RFD] L2 Network namespace infrastructure
Date: Wed, 27 Jun 2007 18:41:25 +0400
Message-ID: <46827715.9040902@sw.ru>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net> <467D3A48.20706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9737 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755779AbXF0OkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 10:40:13 -0400
In-Reply-To: <467D3A48.20706@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>>Eric W. Biederman wrote:
>>  
>>
>>>-- The basic design
>>>
>>>There will be a network namespace structure that holds the global
>>>variables for a network namespace, making those global variables
>>>per network namespace.
>>>
>>>One of those per network namespace global variables will be the
>>>loopback device.  Which means the network namespace a packet resides
>>>in can be found simply by examining the network device or the socket
>>>the packet is traversing.
>>>
>>>Either a pointer to this global structure will be passed into
>>>the functions that need to reference per network namespace variables
>>>or a structure that is already passed in (such as the network device)
>>>will be modified to contain a pointer to the network namespace
>>>structure.
>>>    
>>
>>
>>I believe OpenVZ stores the current namespace somewhere global,
>>which avoids passing the namespace around. Couldn't you do this
>>as well?
>>  
> 
> Will we be able to have a single application be in multiple name-spaces?

Application itself can't be in multiple namespaces in both approaches.
But the objects which belong to the application (e.g. sockets opened by an app)
can belong to different namespaces.

Thanks,
Kirill

