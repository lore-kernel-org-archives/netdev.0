From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net:mv88e6xxx: use g2 interrupt for 6097 chip
Date: Tue, 03 Jan 2017 10:03:13 -0500 (EST)
Message-ID: <20170103.100313.177421213847433744.davem@davemloft.net>
References: <1483438437-19601-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752755AbdACPDP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:03:15 -0500
In-Reply-To: <1483438437-19601-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Tue,  3 Jan 2017 11:13:57 +0100

> @@ -575,6 +575,7 @@ enum mv88e6xxx_cap {
>  	(MV88E6XXX_FLAG_G1_ATU_FID |	\
>  	 MV88E6XXX_FLAG_G1_VTU_FID |	\
>  	 MV88E6XXX_FLAG_GLOBAL2 |	\
> + 	 MV88E6XXX_FLAG_G2_INT |	\

There is a space character before the TAB in this new line you
are adding, please remove it.
