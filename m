From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next RFC 2/9] net_sch: mqprio: Change TC_SETUP_MQPRIO
 to TC_SETUP_QDISC_MQPRIO
Date: Wed, 1 Nov 2017 16:31:34 +0100
Message-ID: <20171101153133.x5agqnsvjss2rnga@netronome.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
 <20171030085613.8697-3-jiri@resnulli.us>
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:48576 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbdKAPbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 11:31:40 -0400
Received: by mail-wm0-f45.google.com with SMTP id p75so5519210wmg.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 08:31:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171030085613.8697-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 09:56:06AM +0100, Jiri Pirko wrote:
> From: Nogah Frankel <nogahf@mellanox.com>
> 
> Change TC_SETUP_MQPRIO to TC_SETUP_QDISC_MQPRIO to match the new
> convention.

Why is there a new convention? This churn in this and the following patch
warrant some justification IMHO.
