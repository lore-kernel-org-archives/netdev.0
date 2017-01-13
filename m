From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v4 3/4] ifstat: Add 64 bits based stats to
 extended statistics
Date: Thu, 12 Jan 2017 17:43:35 -0800
Message-ID: <20170112174335.1bd391c2@xeon-e3>
References: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
        <1484228991-32999-4-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roszenrami@gmail.com,
        roopa@cumulusnetworks.com, jiri@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35255 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750887AbdAMBno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:43:44 -0500
Received: by mail-pf0-f169.google.com with SMTP id f144so22007115pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:43:43 -0800 (PST)
In-Reply-To: <1484228991-32999-4-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 15:49:50 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

> The default stats for ifstat are 32 bits based.
> The kernel supports 64 bits based stats. (They are returned in struct
> rtnl_link_stats64 which is an exact copy of struct rtnl_link_stats, in
> which the "normal" stats are returned, but with fields of u64 instead of
> u32). This patch adds them as an extended stats.
> 
> It is read with filter type IFLA_STATS_LINK_64 and no sub type.
> 
> It is under the name 64bits
> (or any shorten of it as "64")
> 
> For example:
> ifstat -x 64bit
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Other commands (like ip link) always use the 64 bit statistics if available
from the device. I see no reason that ifstat needs to be different.
