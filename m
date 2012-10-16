From: James Kosin <jkosin@intcomgrp.com>
Subject: Re: EG20T and Micrel KSZ9021 Gigabit Ethernet
Date: Tue, 16 Oct 2012 13:21:59 -0400
Message-ID: <507D97B7.5090002@intcomgrp.com>
References: <506F30A2.500@intcomgrp.com> <20121005195343.GA7083@electric-eye.fr.zoreil.com> <506F41FC.7080108@intcomgrp.com> <20121005210910.GA10931@electric-eye.fr.zoreil.com> <507D95A2.9090206@intcomgrp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from server104.appriver.com ([207.97.242.188]:2123 "EHLO
	server104.appriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098Ab2JPRWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:22:01 -0400
Received: from [216.54.13.100] (HELO MAILSRV2010.intcomgrp.com)
  by server104.appriver.com (CommuniGate Pro SMTP 5.4.4)
  with ESMTPS id 8851791 for netdev@vger.kernel.org; Tue, 16 Oct 2012 13:22:00 -0400
In-Reply-To: <507D95A2.9090206@intcomgrp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have to remember to use plain text only....

On 10/16/2012 1:13 PM, James Kosin wrote:
> Hmmm... interesting turn of events.
>
> The problem seems to be in 10 speed support.  I hooked the Ethernet
> PHY to a100TX port and don't get these errors.
>
> James
>
> On 10/5/2012 5:09 PM, Francois Romieu wrote:
>> (please don't top post)
>>
>> James Kosin <jkosin@intcomgrp.com> :
>>> The driver is always reporting:
>>>     [...] pch_gbe: Transfer Carrier Sense Error
>> You should send more information. Say dmesg, link stats (ip link),
>> ethtool information, stats and offload settings.
>>
>> We have a small Micrel ksz9021 phy driver that the pch_gbe driver does
>> not use and the latter pokes into some phy specific register (0x10) that
>> the Micrel document does not include in its list of vendor registers...
>>
>> Does your motherboard vendor offer some linux driver ?
>>
>> /note to myself: pch_gbe should use standard mii.h registers instead
>> of defining its own redundant set of registers.
>>
>> --
>> Ueimor
>>
>
