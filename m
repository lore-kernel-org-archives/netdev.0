From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/7] devlink: Add E-Switch inline mode control
Date: Sun, 8 Jan 2017 11:54:14 +0100
Message-ID: <20170108105414.GC1971@nanopsycho>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
 <1479733561-26601-5-git-send-email-saeedm@mellanox.com>
 <20170108102902.GB1971@nanopsycho>
 <90f3f9f5-beec-be9d-7c92-e6f41f3fd55e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36447 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdAHKyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 05:54:17 -0500
Received: by mail-wm0-f65.google.com with SMTP id m203so15114668wma.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 02:54:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <90f3f9f5-beec-be9d-7c92-e6f41f3fd55e@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jan 08, 2017 at 11:49:20AM CET, ogerlitz@mellanox.com wrote:
>On 1/8/2017 12:29 PM, Jiri Pirko wrote:
>> Mon, Nov 21, 2016 at 02:05:58PM CET, saeedm@mellanox.com wrote:
>> > From: Roi Dayan <roid@mellanox.com>
>> > 
>> > Some HWs need the VF driver to put part of the packet headers on the
>> > TX descriptor so the e-switch can do proper matching and steering.
>> Could you please elaborate a bit about possible use-cases for different
>> modes? Thanks.
>
>As written in the change log, some HW models have this requirement that the
>header set you want eswitch matching on (e.g L2/L3) is present as MD on the
>xmit DMA descriptor.
>
>To address these requirements, following the admin devlink directive the FW
>advertizes that
>to the VF, they are doing so in their xmit logic and the host driver enforces
>that the VF has the proper inline mode before we are willing to offload
>eswitch matching rules. If the VF doesn't obey to the requirement the packets
>are dropped by HW.

Okay, makes sense. Do you expect this will ever have to be needed
per-vf? In general, not only for mlx* drivers. I believe that this is
an e-switch requirement so it should be same for all connected VFs,
right?

Thanks!
