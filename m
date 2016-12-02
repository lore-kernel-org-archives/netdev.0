From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH/RFC net-next 0/2] net/sched: cls_flower: Support matching
 on ICMP
Date: Fri, 2 Dec 2016 18:10:48 +0100
Message-ID: <20161202171048.GE1883@nanopsycho.orion>
References: <1480672352-13291-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S.  Miller" <davem@davemloft.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32910 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753698AbcLBRKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 12:10:51 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so3687842wmu.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 09:10:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480672352-13291-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 02, 2016 at 10:52:30AM CET, simon.horman@netronome.com wrote:
>Hi,
>
>this series add supports for matching on ICMP type and code to cls_flower.
>This is modeled on existing support for matching on L4 ports. The updates
>to the dissector are intended to allow for code and storage re-use.

Looks fine to me. Thanks!


>
>Simon Horman (2):
>  flow dissector: ICMP support
>  net/sched: cls_flower: Support matching on ICMP type and code
>
> drivers/net/bonding/bond_main.c |  6 +++--
> include/linux/skbuff.h          |  5 +++++
> include/net/flow_dissector.h    | 50 ++++++++++++++++++++++++++++++++++++++---
> include/uapi/linux/pkt_cls.h    | 10 +++++++++
> net/core/flow_dissector.c       | 34 +++++++++++++++++++++++++---
> net/sched/cls_flow.c            |  4 ++--
> net/sched/cls_flower.c          | 42 ++++++++++++++++++++++++++++++++++
> 7 files changed, 141 insertions(+), 10 deletions(-)
>
>-- 
>2.7.0.rc3.207.g0ac5344
>
