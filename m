From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: unconditionally set ATU
 trunk
Date: Tue, 28 Mar 2017 22:05:05 -0700 (PDT)
Message-ID: <20170328.220505.1014619882997889859.davem@davemloft.net>
References: <20170328190943.18320-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752697AbdC2FFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:05:07 -0400
In-Reply-To: <20170328190943.18320-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 28 Mar 2017 15:09:43 -0400

> Set the trunk member of the mv88e6xxx_atu_entry structure regardless its
> value, so that uninitialized structures gets the correct boolean value.
> 
> Note that no mainline code is affected by the current behavior.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
