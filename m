From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] ipip: advertise tunnel param via rtnl
Date: Fri, 09 Nov 2012 08:37:00 -0800
Message-ID: <1352479020.19779.741.camel@edumazet-glaptop>
References: <1352467239.19779.564.camel@edumazet-glaptop>
	 <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1352477401-19044-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58152 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab2KIQhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 11:37:03 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so2887838pad.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 08:37:03 -0800 (PST)
In-Reply-To: <1352477401-19044-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 17:09 +0100, Nicolas Dichtel wrote:
> It is usefull for daemons that monitor link event to have the full parameters of
> these interfaces when a rtnl message is sent.
> It allows also to dump them via rtnetlink.
> 
> It is based on what is done for GRE tunnels.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Nice !

Note this also adds support for link creation.

Do you plan to add iproute2 support for :

ip link add ipip1 type ipip remote 10.246.8.36

Thanks

Acked-by: Eric Dumazet <edumazet@google.com>
