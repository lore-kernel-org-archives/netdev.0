From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 10/11] mlxsw: spectrum_router: Request a dump
 of FIB tables during init
Date: Wed, 23 Nov 2016 20:45:48 +0100
Message-ID: <20161123194548.GD1873@nanopsycho>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479912528-4636-1-git-send-email-jiri@resnulli.us>
 <1479916800.4019894.797128001.743EBB6A@webmail.messagingengine.com>
 <20161123160453.GB1873@nanopsycho>
 <1479920345.4035504.797158425.2C10AA0C@webmail.messagingengine.com>
 <20161123170436.GC1873@nanopsycho>
 <1479920903.4037682.797206209.599A8C7A@webmail.messagingengine.com>
 <20161123192230.7uuqwlme3pkrmpyl@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com, kaber@trash.net
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36856 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933908AbcKWTpv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 14:45:51 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so2965528wma.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 11:45:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161123192230.7uuqwlme3pkrmpyl@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 23, 2016 at 08:22:30PM CET, idosch@idosch.org wrote:
>On Wed, Nov 23, 2016 at 06:08:23PM +0100, Hannes Frederic Sowa wrote:
>> On Wed, Nov 23, 2016, at 18:04, Jiri Pirko wrote:
>> > >Sure, but an abort function can be provided to the kernel anyway and the
>> > >driver can care about that.
>> > 
>> > Ok, how?
>> 
>> I think just a sysctl ontop of this series is enough plus a pr_warn.
>> Rocker and mlxsw are responsible to loop for a maximum amount of time.
>
>Maybe, when the module requests a dump it can also provide a callback
>that is invoked following each failed dump?

That would make sense. Thanks.
