From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: spectrum: fix swapped order of arguments packets
 and bytes
Date: Mon, 20 Mar 2017 13:20:42 +0100
Message-ID: <20170320122042.GA1883@nanopsycho.orion>
References: <20170320113722.30311-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:33431 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754363AbdCTM2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 08:28:33 -0400
Received: by mail-wr0-f172.google.com with SMTP id u48so91140984wrc.0
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 05:27:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170320113722.30311-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 20, 2017 at 12:37:22PM CET, colin.king@canonical.com wrote:
>From: Colin Ian King <colin.king@canonical.com>
>
>The arguments packets and bytes to call mlxsw_sp_acl_rule_get_stats are
>in the wrong order. Fix this by swapping them.
>
>Detected by CoverityScan, CID#1419705 ("Arguments in wrong order")
>
>Fixes: 7c1b8eb175b69add8ea ("mlxsw: spectrum: Add support for TC flower offload statistics")
>Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
