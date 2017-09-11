From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Fix EEPROM access in case of
 SFP/SFP+
Date: Mon, 11 Sep 2017 10:41:41 -0700 (PDT)
Message-ID: <20170911.104141.1428817513537310351.davem@davemloft.net>
References: <20170911074226.2020-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        flokli@flokli.de, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdIKRlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 13:41:42 -0400
In-Reply-To: <20170911074226.2020-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 11 Sep 2017 09:42:26 +0200

> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> The current code does not handle correctly the access to the upper page
> in case of SFP/SFP+ EEPROM. In that case the offset should be local
> and the I2C address should be changed.
> 
> Fixes: 2ea109039cd3 ("mlxsw: spectrum: Add support for access cable info via ethtool")
> Reported-by: Florian Klink <flokli@flokli.de>
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks.
