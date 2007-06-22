From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 20:21:51 -0700
Message-ID: <467B404F.2080504@candelatech.com>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net> <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com> <467B2C39.1040208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:48724 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXFVDWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 23:22:05 -0400
In-Reply-To: <467B2C39.1040208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Eric W. Biederman wrote:
>> For the macvlan hash you just use an upper byte.  Is that just a
>> simple starting place, or do we not need a more complex hash.
>>   
> 
> That gave me an idea, since the default addresses are random
> anyway I'm now using an incrementing counter for the upper byte.

Is there not a (relatively) easy way to hash the entire 6 bytes?

I'd prefer to be able to set the MACs to anything I want, without
worrying about trivially hitting a worst-case hash scenario.

Thanks,
Ben

> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

