From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 06:38:59 -0800
Message-ID: <1352903939.4497.6.camel@edumazet-glaptop>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
	 <1352902715.4497.3.camel@edumazet-glaptop>
	 <20121114142941.GA2531@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:40173 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422925Ab2KNOjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 09:39:03 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so306244iay.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 06:39:02 -0800 (PST)
In-Reply-To: <20121114142941.GA2531@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-14 at 15:29 +0100, Jiri Pirko wrote:
> Wed, Nov 14, 2012 at 03:18:35PM CET, eric.dumazet@gmail.com wrote:
> >On Wed, 2012-11-14 at 13:51 +0100, Jiri Pirko wrote:
> >> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
> >> sets this. Correct the check to behave properly on addr removal.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >> ---
> >
> >Please add in the changelog which commit added the bug, to ease
> >stable teams work.
> 
> bug introduced by:
> 
> commit a748ee2426817a95b1f03012d8f339c45c722ae1
> Author: Jiri Pirko <jpirko@redhat.com>
> Date:   Thu Apr 1 21:22:09 2010 +0000
> 
>     net: move address list functions to a separate file

Good, the usual way is then to add in the changelog :

Bug added in commit a748ee242681
(net: move address list functions to a separate file)


(No need to give the author/date, and we can shorten the SHA1 to 10 or
12 digits)

Thanks
