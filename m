From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 2/2] net: skbuff: Coding: Use eth_type_vlan()
 instead of open coding it
Date: Tue, 20 Sep 2016 10:13:07 -0700
Message-ID: <CAOrHB_C9uF3cCp4MQz+_NPsFgxdTqN-AkkkK9NULyC45hJadtw@mail.gmail.com>
References: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com> <1474364917-31710-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:53816 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755542AbcITRNM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:13:12 -0400
Received: from mfilter36-d.gandi.net (mfilter36-d.gandi.net [217.70.178.167])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id EF17641C08A
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:13:10 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter36-d.gandi.net (mfilter36-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id tJsifFjmSHh9 for <netdev@vger.kernel.org>;
        Tue, 20 Sep 2016 19:13:09 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 785E741C094
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:13:09 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id n143so25423268ita.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:13:09 -0700 (PDT)
In-Reply-To: <1474364917-31710-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 2:48 AM, Shmulik Ladkani
<shmulik.ladkani@ravellosystems.com> wrote:
> Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
> skb->protocol to ETH_P_8021Q or ETH_P_8021AD.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Reviewed-by: Pravin B Shelar <pshelar@ovn.org>
