From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [Devel] Re: [RFD] L2 Network namespace infrastructure
Date: Thu, 28 Jun 2007 17:12:01 +0400
Message-ID: <4683B3A1.2040401@sw.ru>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <468276BA.7020309@sw.ru> <46827A8F.6090205@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:11197 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbXF1NMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 09:12:25 -0400
In-Reply-To: <46827A8F.6090205@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Kirill Korotaev wrote:
> 
>>Patrick McHardy wrote:
>>  
>>
>>>I believe OpenVZ stores the current namespace somewhere global,
>>>which avoids passing the namespace around. Couldn't you do this
>>>as well?
>>>    
>>
>>yes, we store a global namespace context on current
>>(can be stored in per-cpu as well).
>>
>>do you prefer this way?
>>  
> 
> For what it's worth, I don't prefer this way as I can see wanting to 
> have one application
> use several namespaces at once....

As I wrote to you in another email, it's not a problem,
since applications itself do not own network namespace.

It is objects like sockets which are binded to net namespace and thus
you can have sockets from different namespaces in one application
regardless of mechanism of context handling we talk about.

Thanks,
Kirill

