From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 2/9] net_sch: mqprio: Change TC_SETUP_MQPRIO
 to TC_SETUP_QDISC_MQPRIO
Date: Thu, 2 Nov 2017 07:48:22 +0100
Message-ID: <20171102064822.GA2024@nanopsycho>
References: <20171030085613.8697-1-jiri@resnulli.us>
 <20171030085613.8697-3-jiri@resnulli.us>
 <20171101153133.x5agqnsvjss2rnga@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, mlxsw@mellanox.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, michael.chan@broadcom.com,
        ganeshgr@chelsio.com, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:46996 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbdKBGsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 02:48:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id m72so8737051wmc.1
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 23:48:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101153133.x5agqnsvjss2rnga@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 01, 2017 at 04:31:34PM CET, simon.horman@netronome.com wrote:
>On Mon, Oct 30, 2017 at 09:56:06AM +0100, Jiri Pirko wrote:
>> From: Nogah Frankel <nogahf@mellanox.com>
>> 
>> Change TC_SETUP_MQPRIO to TC_SETUP_QDISC_MQPRIO to match the new
>> convention.
>
>Why is there a new convention? This churn in this and the following patch
>warrant some justification IMHO.

In the enum, there is CLS*, there should be also similar prefix for
QDICS group. That's it.
