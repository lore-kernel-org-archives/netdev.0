From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Devel] Re: [RFD] L2 Network namespace infrastructure
Date: Wed, 27 Jun 2007 07:56:15 -0700
Message-ID: <46827A8F.6090205@candelatech.com>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <468276BA.7020309@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:37332 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbXF0O55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 10:57:57 -0400
In-Reply-To: <468276BA.7020309@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev wrote:
> Patrick McHardy wrote:
>   
>> I believe OpenVZ stores the current namespace somewhere global,
>> which avoids passing the namespace around. Couldn't you do this
>> as well?
>>     
>
> yes, we store a global namespace context on current
> (can be stored in per-cpu as well).
>
> do you prefer this way?
>   
For what it's worth, I don't prefer this way as I can see wanting to 
have one application
use several namespaces at once....

Thanks,
Ben

> Thanks,
> Kirill
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


