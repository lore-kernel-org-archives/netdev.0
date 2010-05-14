From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual
 port management (was iovnl)
Date: Fri, 14 May 2010 14:56:43 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FF39989D4@rrsmsx501.amr.corp.intel.com>
References: <C812DA73.31839%scofeldm@cisco.com> <4BED91D0.5020407@trash.net>
 <20100514182526.GO5798@x200.localdomain> <4BED9A85.4080507@trash.net>
 <20100514184803.GP5798@x200.localdomain> <4BED9B5B.6010001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Feldman <scofeldm@cisco.com>, Arnd Bergmann <arnd@arndb.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>, Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46487 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758419Ab0ENU5D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 16:57:03 -0400
In-Reply-To: <4BED9B5B.6010001@trash.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Patrick McHardy
>Sent: Friday, May 14, 2010 11:50 AM
>To: Chris Wright
>Cc: Scott Feldman; Arnd Bergmann; davem@davemloft.net;
>shemminger@vyatta.com; netdev@vger.kernel.org
>Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual
>port management (was iovnl)
>
>Chris Wright wrote:
>> * Patrick McHardy (kaber@trash.net) wrote:
>>> Chris Wright wrote:
>>>> * Patrick McHardy (kaber@trash.net) wrote:
>>>>> Scott Feldman wrote:
>>>>>> On 5/14/10 10:29 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>>>>>>
>>>>>>>> I think we should redo the other IFLA_VF_xxx msgs in the same
>style.  I'm
>>>>>>>> not going to tackle that for IFLA_VF_PORTS patch, but it would be
>a good
>>>>>>>> followup patch.
>>>>>>> I fear it's too late for that now. While we have not yet released
>2.6.34
>>>>>>> and 2.6.33 does not contain the broken message, it's extremely
>late in the
>>>>>>> stabilization phase of v2.6.34, so I doubt that there is still a
>chance for
>>>>>>> that at this point.
>>>>>> That's too bad.  I wish Patrick's objections were honored and then
>we
>>>>>> wouldn't have followed that broken model!  Can the broken msgs be
>disabled
>>>>>> somehow for 2.6.34?  Keep the definitions in if_link.h but fail the
>SET/GET
>>>>>> actions in rtnetlink.c?
>>>>> That would be a possibility. Unfortunately I don't think we can fix
>>>>> this in a backwards compatible way.
>>>> $ git describe --contains ebc08a6f47ee76ecad8e9f26c26e6ec9b46ca659
>>>> v2.6.34-rc1~233^2~336
>>>>
>>>> It's not released yet?
>>> Correct, it was added in 2.6.34-rc.
>>
>> AFAICT iproute2 hasn't been released either w/ that support.
>> So, I'll prepare patches to fix it (or disable as Scott mentioned).
>> What do you think?
>
>That would be great, otherwise we'll probably have to support it
>forever.

I'd really like to find a way to fix this, instead of having the functionality disabled.

I know Patrick had objections to how the data structures were set up, but I figured that was something we'd tackle later, especially since the series got merged after Patrick's email, and with no further objection. At that point, things got quiet, I got shuffled onto another project, and we all thought things were OK.

At this point, Scott's work depends on what I did, so it's probably more work to unwind my stuff and respin his, than to just fix mine.

Can we quickly respin the kernel side to take care of Patrick's objections, and work the userspace side over the next week or so? The userspace side is where the real fiddly bits will be. I'll drop what I'm working on and get this taken care of as quickly as I can.

Sorry for the confusion - I thought we were OK, until yesterday.

-Mitch

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
