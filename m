From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v4 net-next 05/10] openvswitch: Simplify labels length logic.
Date: Thu, 9 Feb 2017 13:38:37 -0800
Message-ID: <CAPWQB7EkJf47-qFHpA23dQEMC9QrWTdkioTw9vozOKqUh9D1Pw@mail.gmail.com>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org> <1486668121-45709-6-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        pravin shelar <pshelar@ovn.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:57059 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752642AbdBIVoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:44:38 -0500
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id B2E5D47E8A7
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:40:02 +0100 (CET)
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 0552EFB8A4
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:39:01 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id DDdMWJBj4mfY for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 22:38:59 +0100 (CET)
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 7FDC1FB88B
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 22:38:58 +0100 (CET)
Received: by mail-qk0-f175.google.com with SMTP id s186so19518550qkb.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 13:38:58 -0800 (PST)
In-Reply-To: <1486668121-45709-6-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 February 2017 at 11:21, Jarno Rajahalme <jarno@ovn.org> wrote:
> Since 23014011ba42 ("netfilter: conntrack: support a fixed size of 128
> distinct labels"), the size of conntrack labels extension has fixed to
> 128 bits, so we do not need to check for labels sizes shorter than 128
> at run-time.  This patch simplifies labels length logic accordingly,
> but allows the conntrack labels size to be increased in the future
> without breaking the build.  In the event of conntrack labels
> increasing in size OVS would still be able to deal with the 128 first
> label bits.
>
> Suggested-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
