From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Sat, 23 Jun 2007 13:03:05 -0700
Message-ID: <467D7C79.8080604@candelatech.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com>	<467CF8AC.80103@trash.net>	<467D3A48.20706@candelatech.com> <20070623102640.6f111d7e@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	jamal <hadi@cyberus.ca>, Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Linux Containers <containers@lists.osdl.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:38096 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377AbXFWUI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 16:08:26 -0400
In-Reply-To: <20070623102640.6f111d7e@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>   
>> Will we be able to have a single application be in multiple name-spaces?
>>     
>
> That would break the whole point of namespaces...
>   
I was hoping that I could open a socket in one name-space and another in 
another name
space, and send traffic between them, within a single application.  This 
is basically what I can do now with my
send-to-self patch and (for more clever virtual-routing schemes + NAT, 
with a conn-track
patch that Patrick cooked up for me).  It seems these patches I use are 
not acceptable
for merge, so I was hoping name-spaces might work instead.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


