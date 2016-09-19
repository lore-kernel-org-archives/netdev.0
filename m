From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] net: skbuff: Coding: Use eth_type_vlan() instead
 of open coding it
Date: Mon, 19 Sep 2016 09:20:55 -0700
Message-ID: <1474302055.22679.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
         <1474300400-32362-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35891 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752550AbcISQU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:20:57 -0400
Received: by mail-pf0-f196.google.com with SMTP id n24so7475355pfb.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:20:57 -0700 (PDT)
In-Reply-To: <1474300400-32362-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-19 at 18:53 +0300, Shmulik Ladkani wrote:
> Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
> skb->protocol to ETH_P_8021Q or ETH_P_8021AD.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---

You forgot to explicitly state this was targeting net-next tree.

This is detailed in Documentation/networking/netdev-FAQ.tx

Q: How do I indicate which tree (net vs. net-next) my patch should be
in?
