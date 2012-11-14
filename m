From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 15:29:41 +0100
Message-ID: <20121114142941.GA2531@minipsycho.brq.redhat.com>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
 <1352902715.4497.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:54558 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723Ab2KNO3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:29:45 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so211012eaa.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 06:29:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352902715.4497.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 14, 2012 at 03:18:35PM CET, eric.dumazet@gmail.com wrote:
>On Wed, 2012-11-14 at 13:51 +0100, Jiri Pirko wrote:
>> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
>> sets this. Correct the check to behave properly on addr removal.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>
>Please add in the changelog which commit added the bug, to ease
>stable teams work.

bug introduced by:

commit a748ee2426817a95b1f03012d8f339c45c722ae1
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Thu Apr 1 21:22:09 2010 +0000

    net: move address list functions to a separate file


>
>Thanks
>
>
