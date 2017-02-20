From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: Set event bit after initializing labels.
Date: Sun, 19 Feb 2017 21:50:10 -0800
Message-ID: <CAOrHB_CndmnwGzOJG7Tztp2w=tH=mZ-0TqT3LYOGEQ1AzZCWEA@mail.gmail.com>
References: <1487383918-17894-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:51466 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdBTFuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 00:50:15 -0500
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 7CE55FB87D
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 06:50:13 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id pXgvvL5cCFVm for <netdev@vger.kernel.org>;
        Mon, 20 Feb 2017 06:50:12 +0100 (CET)
Received: from mail-wr0-f169.google.com (mail-wr0-f169.google.com [209.85.128.169])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 25A29FB8A3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 06:50:11 +0100 (CET)
Received: by mail-wr0-f169.google.com with SMTP id s27so10687008wrb.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 21:50:11 -0800 (PST)
In-Reply-To: <1487383918-17894-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 6:11 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Connlabels are included in conntrack netlink event messages only if
> the IPCT_LABEL bit is set in the event cache (see
> ctnetlink_conntrack_event()).  Set it after initializing labels for a
> new connection.
>
> Found upon further system testing, where it was noticed that labels
> were missing from the conntrack events.
>
> Fixes: 193e30967897 ("openvswitch: Do not trigger events for unconfirmed connections.")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
