From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Avoid potential packets
 loss
Date: Wed, 01 Mar 2017 12:52:04 -0500 (EST)
Message-ID: <20170301.125204.1935836569049319635.davem@davemloft.net>
References: <1488268540-1767-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753203AbdCARwV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:52:21 -0500
In-Reply-To: <1488268540-1767-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 28 Feb 2017 08:55:40 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When the structure of the LPM tree changes (f.e., due to the addition of
> a new prefix), we unbind the old tree and then bind the new one. This
> may result in temporary packet loss.
> 
> Instead, overwrite the old binding with the new one.
> 
> Fixes: 6b75c4807db3 ("mlxsw: spectrum_router: Add virtual router management")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
