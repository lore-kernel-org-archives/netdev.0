From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6:examine the IP source address legitimacy
Date: Tue, 27 Aug 2013 05:05:01 -0700
Message-ID: <1377605101.8828.142.camel@edumazet-glaptop>
References: <521C90A0.60708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:42957 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab3H0MFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 08:05:04 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so4712964pbb.20
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 05:05:03 -0700 (PDT)
In-Reply-To: <521C90A0.60708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-27 at 19:42 +0800, Duan Jiong wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> RFC4861 8.1:
> The IP source address of the Redirect is the
> same as the current first-hop router for the
> specified ICMP Destination Address.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---

What about updating the comment around line 1726 ?

       /* RFC2461 8.1:
         *      The IP source address of the Redirect MUST be the same as the current
         *      first-hop router for the specified ICMP Destination Address.
         */

Thanks
