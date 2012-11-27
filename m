From: Shan Wei <shanwei88@gmail.com>
Subject: Re: Fwd: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name
 in seq_printf of rt6_info_route
Date: Tue, 27 Nov 2012 11:17:09 +0800
Message-ID: <50B430B5.1080700@gmail.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58625 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757951Ab2K0DRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 22:17:19 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so5573432pad.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 19:17:18 -0800 (PST)
In-Reply-To: <50AEEF08.4000707@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang said, at 2012/11/23 11:35:
> 2) about %*s:
>  since kernel is an open system, IFNAMSIZ is belong to OS API level for outside
>    it has effect both on individual kernel modules and user mode system call
>    we need obey this rule, and %8s is not match this rule.
>    so %8s is not suitable. (and now we have to choose %16s or %s).

Your patch will change the format of /proc/net/ipv6_route.
Why we need to keep be consistent with user mode?
However user operates device name, no effect on the showing of /proc/net/ipv6_route.

> 
>  for the format of information which seq_printf output:
>    it is not belong to OS API level for outside (at least, for current case, it is true). 
>    so we need not keep 'compatible' of it, so %16s is not necessary.

Can you explain If we don't change to %s, what will happen?

> 
>  for keeping source code simple and clearly:
>    %s is better than %16s.
> 
>  so for result, we should choose %s only (neither %16s nor %8s).
