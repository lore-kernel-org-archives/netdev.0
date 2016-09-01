From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 0/4] net: smsc911x: Move phy and interrupt config
Date: Fri, 2 Sep 2016 00:07:54 +0300
Message-ID: <b2c1378f-d172-a309-e776-918c3e6d571c@cogentembedded.com>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, andrew@lunn.ch, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33067 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756855AbcIAVIE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:08:04 -0400
Received: by mail-lf0-f50.google.com with SMTP id b199so70204743lfe.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 14:07:58 -0700 (PDT)
In-Reply-To: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2016 11:15 PM, Jeremy Linton wrote:

> v2-v3: Move error handing into separate patch, replace a couple cases
>  of fixed errors with the errors being returned from the failing functions.
>  Hoist irq handler.

    This is normally at end of the blurb, also you're supposed to keep all 
version history here.

> The smsc911x driver is doing a number of things in its probe routine that
> should be delayed until the interface is started. Because of this, the module
> cannot be unloaded, the phy states are incorrect/stale if the interface isn't
> running, open's unnecessarily fail causing network configuration problems, and
> the /proc/irq nodes are incorrectly named.

    /proc/interrupts maybe?

> Clean up a number of these problems by moving the mdio and interrupt
> configuration into the smsc911x_open routine.
>
> Jeremy Linton (4):
>   net: smsc911x: Remove multiple exit points from smsc911x_open
>   net: smsc911x: Fix register_netdev, phy startup, driver unload
>     ordering
>   net: smsc911x: Move interrupt handler before open
>   net: smsc911x: Move interrupt allocation to open/stop

    Thank you for your insistence on getting this driver straight! I'll try to 
review/test your patches.

MBR, Sergei
