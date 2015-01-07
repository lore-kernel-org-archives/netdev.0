From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Wed, 07 Jan 2015 14:40:51 -0500
Message-ID: <54AD8BC3.2070609@hp.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com> <1420628662-9930-4-git-send-email-vadim4j@gmail.com> <54AD5458.6000400@hp.com> <20150107173640.GA19586@angus-think.lan> <20150107181112.GA24241@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:44956 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbbAGTky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:40:54 -0500
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com [15.193.200.67])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id CF5B848BB
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2015 19:40:53 +0000 (UTC)
In-Reply-To: <20150107181112.GA24241@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2015 01:11 PM, Vadim Kochan wrote:
> On Wed, Jan 07, 2015 at 07:36:40PM +0200, Vadim Kochan wrote:
>> On Wed, Jan 07, 2015 at 10:44:24AM -0500, Brian Haley wrote:
>>> On 01/07/2015 06:04 AM, Vadim Kochan wrote:
>>>> From: Vadim Kochan <vadim4j@gmail.com>
>>>>
>>>> Allow delete all namespace names by:
>>>>
>>>>     $ ip netns del all
>>>
>>> So I can still create a namespace called 'all', but can't exec in it or delete
>>> it independently with this change.  Perhaps you need to block that as well?
>>> Unless there's some other patch I'm missing?
>>>
>>> -Brian
>> Hm, I did not take it into account ...
>> I will look if I can find another way ...
>>
>> Thanks,
> 
> what about this ?
> 
>     $ ip netns exec / ip link
>     $ ip netns del /
> 
> so it make a sense to be as root directory of bound ns names in /var/run/netns/ ?
> what do you think ?

I think using / is confusing.  And something like -a[ll] as an option doesn't
seem right either.

Or you just trap the name "all" in the add case and don't allow it.

Just my opinion.

-Brian
