From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Tue, 4 Apr 2017 21:21:26 -0700
Message-ID: <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35217 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750712AbdDEEV2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 00:21:28 -0400
Received: by mail-oi0-f67.google.com with SMTP id d2so319177oig.2
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 21:21:28 -0700 (PDT)
In-Reply-To: <20170405022853.8238-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salut Benjamin,

Le 04/04/17 à 19:28, Benjamin Herrenschmidt a écrit :
> This is version 2 of the first batch of updates to the
> ftgmac100 driver.
> 
> Essentially:
> 
>  - A few misc cleanups
>  - Fixing link speed & duplex handling (including dealing with
>    an Aspeed requirement to double reset the controller when
>    the speed changes)
>  - And addition of a reset task workqueue which will be used
>    for delaying the re-initialization of the controller
>  - Fixing a number of issues with how interrupts and NAPI
>    are dealt with.
> 
> Subsequent batches will rework and improve the rx path, the
> tx path, and add a bunch of features and fixes.
> 
> Version 2 addresses some review comments to patches 5 and 10
> (see version history in the respective emails).
> 

This looks pretty good to me, two minor things:

- most drivers keep track of the old status/duplex/pause/link variables
instead of the current one which is already available within struct
phy_device, any particular reason for not doing like the other drivers?

- the need to reset the HW during link changes is just ... well too bad

With that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
