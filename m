From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v2 2/4] openvswitch:
 Refactor recirc key allocation.
Date: Thu, 16 Mar 2017 10:28:27 -0700
Message-ID: <CAOrHB_D9zD8TpMmU-b1reD7dwLicuxJcFX9sakpEcABPkfVVeQ@mail.gmail.com>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org> <1489532891-33497-3-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:38887 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752164AbdCPR30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:29:26 -0400
Received: from mfilter12-d.gandi.net (mfilter12-d.gandi.net [217.70.178.129])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 236F0C5A8F
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:28:30 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([217.70.183.194])
        by mfilter12-d.gandi.net (mfilter12-d.gandi.net [10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 2CBdHmWdyA_O for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 18:28:27 +0100 (CET)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id CD5C6C5A96
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:28:27 +0100 (CET)
Received: by mail-wm0-f42.google.com with SMTP id n11so53856541wma.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:28:27 -0700 (PDT)
In-Reply-To: <1489532891-33497-3-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 4:08 PM, Andy Zhou <azhou@ovn.org> wrote:
> The logic of allocating and copy key for each 'exec_actions_level'
> was specific to execute_recirc(). However, future patches will reuse
> as well.  Refactor the logic into its own function clone_key().
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
