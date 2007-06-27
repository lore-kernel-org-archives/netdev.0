From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: [RFD] L2 Network namespace infrastructure
Date: Wed, 27 Jun 2007 18:39:54 +0400
Message-ID: <468276BA.7020309@sw.ru>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:18509 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756495AbXF0OkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 10:40:15 -0400
In-Reply-To: <467CF8AC.80103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Eric W. Biederman wrote:
> 
>>-- The basic design
>>
>>There will be a network namespace structure that holds the global
>>variables for a network namespace, making those global variables
>>per network namespace.
>>
>>One of those per network namespace global variables will be the
>>loopback device.  Which means the network namespace a packet resides
>>in can be found simply by examining the network device or the socket
>>the packet is traversing.
>>
>>Either a pointer to this global structure will be passed into
>>the functions that need to reference per network namespace variables
>>or a structure that is already passed in (such as the network device)
>>will be modified to contain a pointer to the network namespace
>>structure.
> 
> 
> 
> I believe OpenVZ stores the current namespace somewhere global,
> which avoids passing the namespace around. Couldn't you do this
> as well?

yes, we store a global namespace context on current
(can be stored in per-cpu as well).

do you prefer this way?

Thanks,
Kirill

