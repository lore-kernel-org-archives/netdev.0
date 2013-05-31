From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] snmp6: fix title of IPSTATS_MIB_CSUMERRORS
Date: Fri, 31 May 2013 08:13:56 -0700
Message-ID: <1370013236.5109.100.camel@edumazet-glaptop>
References: <1370006980-27297-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1370007176-30579-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:56823 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614Ab3EaPN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 11:13:58 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so2338938pbb.8
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 08:13:58 -0700 (PDT)
In-Reply-To: <1370007176-30579-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 15:32 +0200, Nicolas Dichtel wrote:
> Follow the same convention than other fields, prefix this stat by 'Ip6'.
> 
> Spotted-by: Fujie Zhao <fujie.zhao@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> In fact, I wonder if we cannot simply remove this stat for IPv6: there is no
> checksum in IPv6, so it will always be 0 (and in fact, this stats is only
> increased in net/ipv4/ip_input.c).

You could put this line in a comment, so that a future reader knows why
we do have a hole.
