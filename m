From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2 2/2] net: skbuff: Coding: Use eth_type_vlan() instead
 of open coding it
Date: Mon, 19 Sep 2016 19:23:10 +0300
Message-ID: <20160919192310.3c5d610d@halley>
References: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474300400-32362-2-git-send-email-shmulik.ladkani@gmail.com>
        <1474302055.22679.89.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35283 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbcISQXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:23:18 -0400
Received: by mail-wm0-f67.google.com with SMTP id 133so15838361wmq.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:23:17 -0700 (PDT)
In-Reply-To: <1474302055.22679.89.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 09:20:55 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-09-19 at 18:53 +0300, Shmulik Ladkani wrote:
> > Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
> > skb->protocol to ETH_P_8021Q or ETH_P_8021AD.
> > 
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > ---  
> 
> You forgot to explicitly state this was targeting net-next tree.

Thanks, was an oversight.
Requires resubmission?
