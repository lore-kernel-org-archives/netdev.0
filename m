From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] net: skbuff: Coding: Use eth_type_vlan() instead
 of open coding it
Date: Mon, 19 Sep 2016 10:37:50 -0700
Message-ID: <1474306670.22679.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474300400-32362-1-git-send-email-shmulik.ladkani@gmail.com>
         <1474300400-32362-2-git-send-email-shmulik.ladkani@gmail.com>
         <1474302055.22679.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160919192310.3c5d610d@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36123 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcISRhx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 13:37:53 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so7550378pfb.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 10:37:53 -0700 (PDT)
In-Reply-To: <20160919192310.3c5d610d@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-19 at 19:23 +0300, Shmulik Ladkani wrote:
> On Mon, 19 Sep 2016 09:20:55 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2016-09-19 at 18:53 +0300, Shmulik Ladkani wrote:
> > > Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
> > > skb->protocol to ETH_P_8021Q or ETH_P_8021AD.
> > > 
> > > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > > ---  
> > 
> > You forgot to explicitly state this was targeting net-next tree.
> 
> Thanks, was an oversight.
> Requires resubmission?

I do not think so.

I only reminded it because it seems many netdev submissions
are forgetting this, and it does not help David Miller job.

Thanks
