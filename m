From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: net: macb: fail when there's no PHY
Date: Fri, 29 Sep 2017 12:35:24 +0530
Message-ID: <CAFcVECLgpVvOCKbWkC=xjkYBnkGo3nv7iN7OkNfH0c-wKFmMKw@mail.gmail.com>
References: <20170921203608.GB30148@grante> <1506029751-25249-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Grant Edwards <grant.b.edwards@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:37537 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdI2HFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 03:05:25 -0400
Received: by mail-qk0-f195.google.com with SMTP id z143so279651qkb.4
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 00:05:25 -0700 (PDT)
In-Reply-To: <1506029751-25249-1-git-send-email-brandon.streiff@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brandon,

On Fri, Sep 22, 2017 at 3:05 AM, Brandon Streiff <brandon.streiff@ni.com> wrote:
>> On Thu, Sep 21, 2017 at 01:05:57PM -0700, Florian Fainelli wrote:
<snip>
>
> I have a board that's in a similar boat. My workaround was to undo
> portions of dacdbb4dfc1a with the following patch; this lets me still
> use fixed-link and have MDIO (to configure a switch), but not require
> a PHY.
>
> There was a patch set last year by Harini Katakam ("net: macb: Add MDIO
> driver for accessing multiple PHY devices") that might ultimately be a
> better approach to tackling this problem, although I haven't seen any
> further chatter on it.

That patch was not backward compatible and I was trying to find a better
solution for a common MDIO bus.
I plan to send a new series next month and work on the review comments.

Regards,
Harini
