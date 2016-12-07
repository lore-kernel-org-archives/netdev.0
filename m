From: Niklas Cassel <nks.gnu@gmail.com>
Subject: Re: [PATCH] [v3] net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause
Date: Wed, 7 Dec 2016 10:13:54 +0100
Message-ID: <CAD5ja61A3diBgYwscUSoxJqE1ydmzr+cQ9rR+8uZa0mw-0m_3Q@mail.gmail.com>
References: <1481070443-15118-1-git-send-email-timur@codeaurora.org>
 <2c2aaf1d-05a5-d2bc-d04a-79224a4c6b43@gmail.com> <58476ACB.3030206@codeaurora.org>
 <f62595d4-2dd7-9cc3-7537-2ff186dadc8c@gmail.com> <58477A03.6000107@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>, jon.mason@broadcom.com,
        netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37812 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcLGJOL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:14:11 -0500
Received: by mail-wm0-f53.google.com with SMTP id t79so156151729wmt.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 01:13:56 -0800 (PST)
In-Reply-To: <58477A03.6000107@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You might want to include drivers/net/phy/dp83848.c in your patch.
Support for pause frames in that phy was recently added to netdev-next.


On Wed, Dec 7, 2016 at 3:54 AM, Timur Tabi <timur@codeaurora.org> wrote:
> Florian Fainelli wrote:
>>
>> which is why this made me think the & (SUPPORTED_Pause |
>> SUPPPORTED_Asym_Pause) here is most likely redundant?
>
>
> Well, like I said, better safe than sorry.  I'd rather keep the &= unless
> you have a strong objection.
>
>
> --
> Sent by an employee of the Qualcomm Innovation Center, Inc.
> The Qualcomm Innovation Center, Inc. is a member of the
> Code Aurora Forum, hosted by The Linux Foundation.
