From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/8] Add support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 09:10:51 +0200
Message-ID: <20170328071051.GB1873@nanopsycho.orion>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
 <20170327.154834.1733255928137862540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:35318 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754313AbdC1HK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 03:10:56 -0400
Received: by mail-wr0-f175.google.com with SMTP id u1so89418747wra.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 00:10:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170327.154834.1733255928137862540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 28, 2017 at 12:48:34AM CEST, davem@davemloft.net wrote:
>
>Please fix up these warnings and resubmit:
>
>drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c: In function ‘mlxsw_sp_rif_counter_free’:
>drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:208:2: warning: ‘p_counter_index’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>  mlxsw_sp_rif_counter_edit(mlxsw_sp, rif->rif_index,
>  ^

This is I believe also gcc bug. Code looks fine. I'm not getting the warning
with gcc 6
