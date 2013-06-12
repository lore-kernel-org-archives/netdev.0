From: Ben Greear <greearb@candelatech.com>
Subject: Re: kmemleak reports in kernel 3.9.5+
Date: Tue, 11 Jun 2013 17:28:13 -0700
Message-ID: <51B7C09D.9020402@candelatech.com>
References: <51B61982.2050903@candelatech.com> <CAHkRjk5SDCbqr0Br24YQuHr=j7DmnpYk9CShrz1qiuYff7+qAw@mail.gmail.com> <51B78009.2060808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50189 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755316Ab3FLA2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 20:28:20 -0400
In-Reply-To: <51B78009.2060808@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2013 12:52 PM, Ben Greear wrote:
> On 06/10/2013 03:32 PM, Catalin Marinas wrote:
>> On 10 June 2013 19:22, Ben Greear <greearb@candelatech.com> wrote:
>>> We had a system go OOM while doing lots of wireless
>>> stations.  (System had 8GB of RAM, so I suspect a leak).
>>>
>>> I enabled kmemleak in a 3.9.5 (plus some local patches) and
>>> I see the entries below.  Any idea if these are real or not?

Most of this went away when I disabled SLUB debugging and other
kernel hacking options.  The wifi cfg80211_inform_bss_frame
remains, however.  I'll go dig some more on that tomorrow...didn't
see anything obvious at first glance.

But, perhaps there could be some improvements to
kmemleak to make it deal better with the various kernel
debugging features?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
