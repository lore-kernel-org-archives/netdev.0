From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH] net: ipv6: change %8s to %s for rt->dst.dev->name in
 seq_printf of rt6_info_route
Date: Fri, 02 Nov 2012 23:40:03 +0800
Message-ID: <5093E953.5020709@gmail.com>
References: <50938A65.6040507@asianux.com> <5093BA27.3090109@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35731 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441Ab2KBPkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 11:40:18 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so2536012pad.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 08:40:17 -0700 (PDT)
In-Reply-To: <5093BA27.3090109@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chen Gang said, at 2012/11/2 20:18:
> 
>   the length of rt->dst.dev->name is 16 (IFNAMSIZ)
>   in seq_printf, it is not suitable to use %8s for rt->dst.dev->name.
>   so change it to %s, since each line has not been solid any more.
> 
>   additional information:
> 
>     %8s  limit the width, not for the original string output length
>          if name length is more than 8, it still can be fully displayed.
>          if name length is less than 8, the ' ' will be filled before name.
> 
>     %.8s truly limit the original string output length (precision)
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

1. not to send same patch triple times. 
2. config your email client,because tab is changed to space.
   you can read Documentation/email-clients.txt.
