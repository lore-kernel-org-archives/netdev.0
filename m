From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [patch net-next 2/4] net: sched: move the can_offload check
 from binding phase to rule insertion phase
Date: Wed, 25 Oct 2017 15:09:17 -0700
Message-ID: <20171025150917.6d194051@cakuba.netronome.com>
References: <20171025143500.28973-1-jiri@resnulli.us>
        <20171025143500.28973-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:37996 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932211AbdJYWJa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 18:09:30 -0400
In-Reply-To: <20171025143500.28973-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Oct 2017 16:34:58 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This restores the original behaviour before the block callbacks were
> introduced. Allow the drivers to do binding of block always, no matter
> if the NETIF_F_HW_TC feature is on or off. Move the check to the block
> callback which is called for rule insertion.
> 
> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Could you explain why not add this check to the core?  IIUC every
driver will have to duplicate it if we want to keep the behaviour
of tc offloads we have today.
