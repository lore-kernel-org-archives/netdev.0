From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Mon, 08 May 2017 12:53:28 -0400 (EDT)
Message-ID: <20170508.125328.1653935947017129227.davem@davemloft.net>
References: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com, LinoSanfilippo@gmx.de,
        simon.edelhaus@aquantia.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753457AbdEHQx3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 12:53:29 -0400
In-Reply-To: <9ea5a2ba21b4f8b22a63acf39135a41e2f1da23c.1493928470.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Thu,  4 May 2017 23:10:56 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> This patch fixes the crash that happens when driver tries to collect statistics
> from already released "aq_vec" object.
> If adapter is in "down" state we still allow user to see statistics from HW.
> 
> V2: fixed braces around "aq_vec_free".
> 
> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Applied, thanks.
