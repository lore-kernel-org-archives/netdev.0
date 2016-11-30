From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: ipv4: Don't crash if passing a null sk to ip_rt_update_pmtu.
Date: Wed, 30 Nov 2016 08:46:08 -0800
Message-ID: <CAKD1Yr0_-jpP3B_WWbde5kRE7szE0m7p7U_G8v3evHY5mNNEnw@mail.gmail.com>
References: <1480442207-43618-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36790 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcK3Qqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:46:30 -0500
Received: by mail-io0-f176.google.com with SMTP id m5so220494131ioe.3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:46:30 -0800 (PST)
In-Reply-To: <1480442207-43618-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 9:56 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
> Commit e2d118a1cb5e ("net: inet: Support UID-based routing in IP
> protocols.") made __build_flow_key call sock_net(sk) to determine
> the network namespace of the passed-in socket. This crashes if sk
> is NULL.

Since I missed this in the patch description: this is targeted to
net-next (the code it fixes is not in net yet). Also:

Fixes: e2d118a1cb5e ("net: inet: Support UID-based routing in IP protocols.")
