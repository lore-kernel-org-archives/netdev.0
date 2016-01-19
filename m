From: Joe Stringer <joe@ovn.org>
Subject: Re: nf_unregister_net_hook: hook not found!
Date: Tue, 19 Jan 2016 13:58:00 -0800
Message-ID: <CAPWQB7HiD5q3QL7igYvkdRJ-O5BtS8Yt1OEkeJAJdvDY=nVsgg@mail.gmail.com>
References: <8312456317d37de2b445bbece288b268@eikelenboom.it>
 <20151230001259.GA1637@salvia> <874mf0d5i1.fsf@x220.int.ebiederm.org> <52794c2a10ac78199c3912ccf1f97990@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ebiederm@xmission.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, netfilter@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:36679 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252AbcASWBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 17:01:23 -0500
In-Reply-To: <52794c2a10ac78199c3912ccf1f97990@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 December 2015 at 10:15, Sander Eikelenboom <linux@eikelenboom.it> wrote:
> On 2015-12-30 03:39, ebiederm@xmission.com wrote:
>>
>> Pablo Neira Ayuso <pablo@netfilter.org> writes:
>>
>>> On Mon, Dec 28, 2015 at 09:05:03PM +0100, Sander Eikelenboom wrote:
>>>>
>>>> Hi,
>>>>
>>>> Running a 4.4.0-rc6 kernel i encountered the warning below.
>>>
>>>
>>> Cc'ing Eric Biederman.
>>>
>>> @Sander, could you provide a way to reproduce this?
>>
>>
>> I am on vacation until the new year, but if this is reproducible we
>> should be able to print out reg, reg->pf, reg->hooknum, reg->hook
>> to figure out which hook is having something very weird happen to it.
>>
>> This is happening in some network namespace exit.
>>
>> Eric
>>
>
> Unfortunately i have found no way to reproduce,
> 13 seconds implies it was at boot, but i only have seen this once.

How about this script?

#!/bin/sh

ip netns add at_ns0
ip netns del at_ns0
modprobe nf_conntrack_ipv4
modprobe -r nf_conntrack_ipv4
