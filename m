From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] iproute:  Support cross-compiling.
Date: Tue, 15 Nov 2011 18:41:53 -0800
Message-ID: <4EC322F1.8080309@candelatech.com>
References: <1321405482-18445-1-git-send-email-greearb@candelatech.com> <20111115171722.02fa1c77@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52248 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604Ab1KPClz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 21:41:55 -0500
In-Reply-To: <20111115171722.02fa1c77@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2011 05:17 PM, Stephen Hemminger wrote:
> On Tue, 15 Nov 2011 17:04:42 -0800
> greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This lets users use their own compiler instead of
>> hard-coding to use gcc.
>>
>> Also adds tests to disable some things that were not supported
>> in my ARM cross-compile toolchain.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> Can't you do this by setting up the compile environment better?
> I would rather have the tools work with all features and handle
> errors from kernel rather than neutering it.

At the least, the parts that let you use your own CC could
be split out and applied?

I've no interest in trying to fix whatever is wrong with my
tool chain..just not worth the effort since I don't need
network namespaces and I don't need the arp daemon.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
