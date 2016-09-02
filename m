From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH net-next v21 2/4] vlan: Check for vlan ethernet
 types for 8021.q or 802.1ad
Date: Fri, 2 Sep 2016 14:41:53 -0700
Message-ID: <CAOrHB_BUVYB7BqfcQEMP+zOvEg6rTq_Uy+YVAUPK=H0q2B_2bA@mail.gmail.com>
References: <1472762727-25844-1-git-send-email-e@erig.me> <1472762727-25844-3-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Thomas F Herbert <thomasfherbert@gmail.com>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:58035 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbcIBVl5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 17:41:57 -0400
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id BDBE441C08B
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 23:41:56 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id gZ-CfGV7D3vA for <netdev@vger.kernel.org>;
        Fri,  2 Sep 2016 23:41:55 +0200 (CEST)
Received: from mail-it0-f51.google.com (mail-it0-f51.google.com [209.85.214.51])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 57EAD41C088
        for <netdev@vger.kernel.org>; Fri,  2 Sep 2016 23:41:55 +0200 (CEST)
Received: by mail-it0-f51.google.com with SMTP id e124so61042275ith.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 14:41:55 -0700 (PDT)
In-Reply-To: <1472762727-25844-3-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 1:45 PM, Eric Garver <e@erig.me> wrote:
> This is to simplify using double tagged vlans. This function allows all
> valid vlan ethertypes to be checked in a single function call.
> Also replace some instances that check for both ETH_P_8021Q and
> ETH_P_8021AD.
>
> Patch based on one originally by Thomas F Herbert.
>
> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> Signed-off-by: Eric Garver <e@erig.me>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
