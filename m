From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v2 10/11] mlxsw: spectrum_router: Request a dump of
 FIB tables during init
Date: Wed, 23 Nov 2016 18:08:23 +0100
Message-ID: <1479920903.4037682.797206209.599A8C7A@webmail.messagingengine.com>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479912528-4636-1-git-send-email-jiri@resnulli.us>
 <1479916800.4019894.797128001.743EBB6A@webmail.messagingengine.com>
 <20161123160453.GB1873@nanopsycho>
 <1479920345.4035504.797158425.2C10AA0C@webmail.messagingengine.com>
 <20161123170436.GC1873@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        arkadis@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:51466 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751895AbcKWRIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:08:24 -0500
In-Reply-To: <20161123170436.GC1873@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016, at 18:04, Jiri Pirko wrote:
> >Sure, but an abort function can be provided to the kernel anyway and the
> >driver can care about that.
> 
> Ok, how?

I think just a sysctl ontop of this series is enough plus a pr_warn.
Rocker and mlxsw are responsible to loop for a maximum amount of time.

Otherwise, if more fancy, can we provide an
fib_inconsistency_notification function pointer in netdev_ops?

Bye and thanks,
Hannes
