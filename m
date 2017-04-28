From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] geneve: fix incorrect setting of UDP checksum flag
Date: Fri, 28 Apr 2017 11:58:06 -0700
Message-ID: <CAOrHB_DdSPYRBqc7cAszgfNf6Tp1=ZzhhxTOjkFeBKAsk2arPQ@mail.gmail.com>
References: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:37297 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999348AbdD1TAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:00:03 -0400
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net [217.70.183.199])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 2273A47A91F
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 20:58:10 +0200 (CEST)
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
        by relay9-d.mail.gandi.net (Postfix) with ESMTPS id C1F43402D7
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 20:58:08 +0200 (CEST)
Received: from mfilter21-d.gandi.net (mfilter21-d.gandi.net [217.70.178.149])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id AF361FB87E
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 20:58:08 +0200 (CEST)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter21-d.gandi.net (mfilter21-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3ZVqjDDjb80O for <netdev@vger.kernel.org>;
        Fri, 28 Apr 2017 20:58:07 +0200 (CEST)
Received: from mail-wr0-f173.google.com (mail-wr0-f173.google.com [209.85.128.173])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 6589FFB89F
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 20:58:07 +0200 (CEST)
Received: by mail-wr0-f173.google.com with SMTP id z52so38379302wrc.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 11:58:07 -0700 (PDT)
In-Reply-To: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 2:11 PM, Girish Moodalbail
<girish.moodalbail@oracle.com> wrote:
> Creating a geneve link with 'udpcsum' set results in a creation of link
> for which UDP checksum will NOT be computed on outbound packets, as can
> be seen below.
>
> 11: gen0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>     link/ether c2:85:27:b6:b4:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     geneve id 200 remote 192.168.13.1 dstport 6081 noudpcsum
>
> Similarly, creating a link with 'noudpcsum' set results in a creation
> of link for which UDP checksum will be computed on outbound packets.
>
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

LGTM.
Acked-by: Pravin B Shelar <pshelar@ovn.org>
