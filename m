From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Wed, 18 Oct 2017 15:01:08 +0200
Message-ID: <20171018130108.GC1975@nanopsycho.orion>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
 <20171018073151.GC2028@nanopsycho>
 <CA+Jmh7Eit_BBvkJNUdF4QYwCuP5T7WCkR4O_X9DK8O0CEzAjTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:45800 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdJRNBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:01:10 -0400
Received: by mail-wm0-f51.google.com with SMTP id q124so9917476wmb.0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 06:01:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7Eit_BBvkJNUdF4QYwCuP5T7WCkR4O_X9DK8O0CEzAjTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 18, 2017 at 02:39:42PM CEST, steven.lin1@broadcom.com wrote:
>On Wed, Oct 18, 2017 at 3:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> You need to split the config option to those that are per-port and to
>> those that are per-asic. For each family, you have to use ither
>> devlink_port of devlink handle. Also, you need to split into those that are
>> permanent and to those who are teporary (until reset). I think you might
>> need some flags for that.
>>
>
>All these are permanent; none are temporary - that's (partially) why
>we consider these to be devlink/device parameters rather than a
>netdev/ethtool thing, since they take effect after the next reset and
>before any drivers are loaded (i.e. the card uses these parameters for
>its default/startup configuration).

Understood. But I think that this iface should be capable to serve the
options of non-permanent as well. Or this could be 2 separate interfaces
with 2 separate cmd pair. Thoughts?


>
>I will take a closer look at splitting these between per-port and per-asic.
>
>Thanks,
>Steve
