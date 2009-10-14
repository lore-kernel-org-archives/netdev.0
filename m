From: Luca Deri <deri@ntop.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 23:34:53 +0200
Message-ID: <C19A7559-6C48-4F2D-8052-529DC63F046E@ntop.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <20091014090125.535ee0dc@nehalam> <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com> <20091014123328.1ebe35ea@s6510> <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014203640.GB32317@ioremap.net> <4AD64251.50903@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jake.unipi.it ([131.114.21.22]:35240 "EHLO jake.ntop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbZJNVfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 17:35:37 -0400
In-Reply-To: <4AD64251.50903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben
the patch implements what I looked for.

Thanks Luca

On Oct 14, 2009, at 11:27 PM, Ben Greear wrote:

> On 10/14/2009 01:36 PM, Evgeniy Polyakov wrote:
>> On Wed, Oct 14, 2009 at 10:17:30PM +0200, Luca Deri (deri@ntop.org)  
>> wrote:
>>> The reason why I decided to patch dev.c is because I wanted  
>>> PF_RING to
>>> decide whether the packet journey shall continue or not. In other
>>> words with my solution PF_RING applications can decide whether the
>>> received packets will also be delivered to upper layers (and to  
>>> other
>>> kernel network components). This configurable 'early packet drop'
>>> allows the overall performance to be significantly increased as
>>> received packets are not supposed to be delivered to upper layers;
>>> this is a typical situations for many monitoring devices.
>>
>> This is a feature many projects implement themself indeed. What about
>> creating special return value from the packet handler which will
>> indicate that packet was already consumed and no further work  
>> should be
>> done on it?
>
> Maybe something similar to the attached patch?
>
> Thanks,
> Ben
>
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
>
> <patch0.patch>

