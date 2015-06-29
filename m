From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string "marvell,
 armada-xp-neta"
Date: Mon, 29 Jun 2015 15:03:10 +0200
Message-ID: <5591420E.30700@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org> <1434547162-6275-2-git-send-email-simon.guinot@sequanux.org> <55818E64.20007@free-electrons.com> <55818F10.8030304@free-electrons.com> <20150617170112.GD2917@io.lakedaemon.net> <20150619123253.GB4853@kw.sim.vm.gnt> <20150625091323.GH4853@kw.sim.vm.gnt> <20150625132009.GC23515@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>,
	Simon Guinot <simon.guinot@sequanux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47925 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753041AbbF2NDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 09:03:13 -0400
In-Reply-To: <20150625132009.GC23515@io.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason, Simon,

On 25/06/2015 15:20, Jason Cooper wrote:
> On Thu, Jun 25, 2015 at 11:13:23AM +0200, Simon Guinot wrote:
>> On Fri, Jun 19, 2015 at 02:32:53PM +0200, Simon Guinot wrote:
>>> On Wed, Jun 17, 2015 at 05:01:12PM +0000, Jason Cooper wrote:
>>>> On Wed, Jun 17, 2015 at 05:15:28PM +0200, Gregory CLEMENT wrote:
>>>>> On 17/06/2015 17:12, Gregory CLEMENT wrote:
>>>>>> On 17/06/2015 15:19, Simon Guinot wrote:
>>>>>>> The mvneta driver supports the Ethernet IP found in the Armada 370, XP,
>>>>>>> 380 and 385 SoCs. Since at least one more hardware feature is available
>>>>>>> for the Armada XP SoCs then a way to identify them is needed.
>>>>>>>
>>>>>>> This patch introduces a new compatible string "marvell,armada-xp-neta".
>>>>>>
>>>>>> Let's be future proof by going further. I would like to have an compatible string
>>>>>> for each SoC even if we currently we don't use them.
>>>>
>>>> I disagree with this.  We can't predict what incosistencies we'll discover in
>>>> the future.  We should only assign new compatible strings based on known IP
>>>> variations when we discover them.  This seems fraught with demons since we
>>>> can't predict the scope of affected IP blocks (some steppings of one SoC, three
>>>> SoCs plus two steppings of a fourth, etc)
>>>>
>>>> imho, the 'future-proofing' lies in being specific as to the naming of the
>>>> compatible strings against known hardware variations at the time.
>>>
>>> So, should I add more compatible strings or not ?
>>
>> How do you want me to handle this ? Did you reach an agreement ?
> 
> Sorry, this slipped off my radar.  Probably EBKAC.  :)
> 
> I'm still of the opinion that future-proofing equates to guessing.
> It has the advantage of, if we guess correctly, things are easier down
> the road when we discover differences between similar IP blocks.
> However, if we guess incorrectly, then we have a mess on our hands.
> iow, this proposal fails poorly.
> 
> I've no problem breaking DT compatibility when it's determined that we
> made a mistake (or mistakes) in the past.  See the irqchip rework that
> Marc did a few cycles ago.
> 
> The difference here is that we know better.  We *know* that dtbs are
> upgraded with the kernel.  We *know* that no one is shipping products
> with dtbs in ROMs.  So what are we really trying to protect against?

Ok then, if we don't have to ensure backward compatibility, then the patch
is fine as is.



Thanks,

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
