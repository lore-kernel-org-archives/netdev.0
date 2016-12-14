From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 1/3] openvswitch: Add a missing break statement.
Date: Tue, 13 Dec 2016 21:07:08 -0800
Message-ID: <CAOrHB_By4AoojkiA33bP3GT7ABsdZfJkp9j2kGpno76j9cqXug@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>, Eric Garver <e@erig.me>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:60889 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750698AbcLNFHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 00:07:15 -0500
Received: from mfilter49-d.gandi.net (mfilter49-d.gandi.net [217.70.178.180])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id A1C31A80C7
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 06:07:11 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter49-d.gandi.net (mfilter49-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Uv79Nn_RkBot for <netdev@vger.kernel.org>;
        Wed, 14 Dec 2016 06:07:10 +0100 (CET)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 2554FA80CF
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 06:07:10 +0100 (CET)
Received: by mail-io0-f175.google.com with SMTP id p42so22262130ioo.1
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 21:07:09 -0800 (PST)
In-Reply-To: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 3:30 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
> Add a break statement to prevent fall-through from
> OVS_KEY_ATTR_ETHERNET to OVS_KEY_ATTR_TUNNEL.  Without the break
> actions setting ethernet addresses fail to validate with log messages
> complaining about invalid tunnel attributes.
>
> Fixes: 0a6410fbde ("openvswitch: netlink: support L3 packets")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> Acked-by: Jiri Benc <jbenc@redhat.com>

Hi Jarno,
Since this is straight forward patch. can you send it separately so
that we can get it merged soon?

Thanks,
Pravin.
