From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: sched: block callbacks follow-up
Date: Wed, 1 Nov 2017 11:41:07 +0100
Message-ID: <20171101104107.GF1977@nanopsycho.orion>
References: <20171025143500.28973-1-jiri@resnulli.us>
 <20171029.183632.1515928020513719137.davem@davemloft.net>
 <20171029111714.GB2635@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:54383 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbdKAKlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:41:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id r68so4030199wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 03:41:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171029111714.GB2635@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 29, 2017 at 12:17:14PM CET, jiri@resnulli.us wrote:
>Sun, Oct 29, 2017 at 10:36:32AM CET, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Wed, 25 Oct 2017 16:34:56 +0200
>>
>>> This patchset does a bit of cleanup of leftovers after block callbacks
>>> patchset. The main part is patch 2, which restores the original handling
>>> of tc offload feature flag.
>>
>>Jiri, this series does not apply cleanly to net-next.
>
>I will respin.
>
>
>>
>>Also, you should really work out the block offload semantics
>>with Jakub, continuing the discussion of patch #2.
>
>I have some ideas. I could let driver to enable/disable already
>registered callback. Will look at it.

The cb enable disable according to NETIF_F_HW_TC ethtool flag could be
done. It will require some additional work in many drivers. Most of the
drivers do not effect the flag change.

I will rebase and repost this patchset for now to fix the regression
and work on NETIF_F_HW_TC handling in a follow-up.
