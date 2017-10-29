From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: sched: block callbacks follow-up
Date: Sun, 29 Oct 2017 12:17:14 +0100
Message-ID: <20171029111714.GB2635@nanopsycho>
References: <20171025143500.28973-1-jiri@resnulli.us>
 <20171029.183632.1515928020513719137.davem@davemloft.net>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:52334 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdJ2LRR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 07:17:17 -0400
Received: by mail-wm0-f68.google.com with SMTP id t139so11047330wmt.1
        for <netdev@vger.kernel.org>; Sun, 29 Oct 2017 04:17:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171029.183632.1515928020513719137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 29, 2017 at 10:36:32AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 25 Oct 2017 16:34:56 +0200
>
>> This patchset does a bit of cleanup of leftovers after block callbacks
>> patchset. The main part is patch 2, which restores the original handling
>> of tc offload feature flag.
>
>Jiri, this series does not apply cleanly to net-next.

I will respin.


>
>Also, you should really work out the block offload semantics
>with Jakub, continuing the discussion of patch #2.

I have some ideas. I could let driver to enable/disable already
registered callback. Will look at it.
