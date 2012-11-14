From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 16:22:25 +0100
Message-ID: <20121114152225.GB2531@minipsycho.brq.redhat.com>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
 <1352902715.4497.3.camel@edumazet-glaptop>
 <20121114142941.GA2531@minipsycho.brq.redhat.com>
 <1352903939.4497.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:60603 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964811Ab2KNPWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:22:31 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so522151vcb.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 07:22:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352903939.4497.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 14, 2012 at 03:38:59PM CET, eric.dumazet@gmail.com wrote:
>On Wed, 2012-11-14 at 15:29 +0100, Jiri Pirko wrote:
>> Wed, Nov 14, 2012 at 03:18:35PM CET, eric.dumazet@gmail.com wrote:
>> >On Wed, 2012-11-14 at 13:51 +0100, Jiri Pirko wrote:
>> >> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
>> >> sets this. Correct the check to behave properly on addr removal.
>> >> 
>> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> ---
>> >
>> >Please add in the changelog which commit added the bug, to ease
>> >stable teams work.
>> 
>> bug introduced by:
>> 
>> commit a748ee2426817a95b1f03012d8f339c45c722ae1
>> Author: Jiri Pirko <jpirko@redhat.com>
>> Date:   Thu Apr 1 21:22:09 2010 +0000
>> 
>>     net: move address list functions to a separate file
>
>Good, the usual way is then to add in the changelog :
>
>Bug added in commit a748ee242681
>(net: move address list functions to a separate file)
>
>
>(No need to give the author/date, and we can shorten the SHA1 to 10 or
>12 digits)

Mind noted. Thanks Eric.

>
>Thanks
>
>
