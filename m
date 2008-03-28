From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: COMPLETE is a poor global identifier
Date: Fri, 28 Mar 2008 19:08:06 +0100
Message-ID: <47ED3406.5050506@gmail.com>
References: <20080328032449.cbc09f3b.akpm@linux-foundation.org>	<20080328153833.1074868a@hyperion.delvare> <20080328105321.07873d93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jean Delvare <khali@linux-fr.org>, i2c@lm-sensors.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:7779 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757016AbYC1SIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 14:08:22 -0400
Received: by ug-out-1314.google.com with SMTP id z38so810714ugc.16
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 11:08:21 -0700 (PDT)
In-Reply-To: <20080328105321.07873d93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2008 06:53 PM, Andrew Morton wrote:
> On Fri, 28 Mar 2008 15:38:33 +0100 Jean Delvare <khali@linux-fr.org> wrote:
> 
>> Hi Andrew,
>>
>> On Fri, 28 Mar 2008 03:24:49 -0700, Andrew Morton wrote:
>>> powerpc allmodconfig:
>>>
>>> In file included from drivers/char/rio/rio_linux.c:81:
>>> drivers/char/rio/cirrus.h:202:1: warning: "COMPLETE" redefined
>>> In file included from include/net/netns/ipv4.h:8,
>>>                  from include/net/net_namespace.h:13,
>>>                  from include/linux/seq_file.h:7,
>>>                  from include/asm/machdep.h:12,
>>>                  from include/asm/pci.h:17,
>>>                  from include/linux/pci.h:951,
>>>                  from drivers/char/rio/rio_linux.c:50:
>>> include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
>>>
>>> In file included from drivers/char/ip2/ip2main.c:128:
>>> drivers/char/ip2/i2ellis.h:608:1: warning: "COMPLETE" redefined
>>> In file included from include/net/netns/ipv4.h:8,
>>>                  from include/net/net_namespace.h:13,
>>>                  from include/linux/seq_file.h:7,
>>>                  from include/asm/machdep.h:12,
>>>                  from include/asm/pci.h:17,
>>>                  from include/linux/pci.h:951,
>>>                  from drivers/char/ip2/ip2main.c:95:
>>> include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
>>>
>>>
>>> they should all be renamed.  These can cause runtime failures, so it's not
>>> a trivial thing.
>> How is this related to i2c?
> 
> uh, I guess at 3:24AM ip2 and i2c look the same.

I'll take care of both, thanks.
