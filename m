From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 04 Jan 2013 07:45:20 -0800
Message-ID: <1357314320.1678.1414.camel@edumazet-glaptop>
References: <20130104105955.GA3663@raven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:35521 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab3ADPpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 10:45:24 -0500
Received: by mail-pb0-f44.google.com with SMTP id uo1so9219954pbc.3
        for <netdev@vger.kernel.org>; Fri, 04 Jan 2013 07:45:23 -0800 (PST)
In-Reply-To: <20130104105955.GA3663@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 10:59 +0000, Tom Parkin wrote:
> Hi list,
> 
> I recently tripped over a NULL pointer dereference in the veth driver.
> I'm running a 3.8.0_rc1 (updated from net-next git tree this morning)
> on an Athlon 64 X2 machine running a 32 bit kernel.  To trigger the
> oops I simply created a veth interface as follows:
> 
>         ip link add name ve0 type veth peer name ve1
> 
> I did a little digging in the git history and I note that veth
> statistics changed a little with commit 2681128f0ced8aa4.  I tried
> reverting that commit in my tree, which made the oops go away again.
> 
> Thanks,
> Tom

Thanks Tom, I'll fix this.
