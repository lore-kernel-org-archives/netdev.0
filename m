From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Wed, 18 Oct 2017 08:39:42 -0400
Message-ID: <CA+Jmh7Eit_BBvkJNUdF4QYwCuP5T7WCkR4O_X9DK8O0CEzAjTA@mail.gmail.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com> <20171018073151.GC2028@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:50722 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934046AbdJRMkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:40:04 -0400
Received: by mail-qt0-f171.google.com with SMTP id d9so3184367qtd.7
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 05:40:03 -0700 (PDT)
In-Reply-To: <20171018073151.GC2028@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 3:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
> You need to split the config option to those that are per-port and to
> those that are per-asic. For each family, you have to use ither
> devlink_port of devlink handle. Also, you need to split into those that are
> permanent and to those who are teporary (until reset). I think you might
> need some flags for that.
>

All these are permanent; none are temporary - that's (partially) why
we consider these to be devlink/device parameters rather than a
netdev/ethtool thing, since they take effect after the next reset and
before any drivers are loaded (i.e. the card uses these parameters for
its default/startup configuration).

I will take a closer look at splitting these between per-port and per-asic.

Thanks,
Steve
