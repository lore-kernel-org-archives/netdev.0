From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V3 5/8] net/mlx4_en: Adding support of turning
 off link autonegotiation via ethtool
Date: Mon, 30 Jan 2017 14:00:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0273B7E@AcuExch.aculab.com>
References: <1485708980-23468-1-git-send-email-tariqt@mellanox.com>
 <1485708980-23468-6-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>
To: 'Tariq Toukan' <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.189]:64870 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932260AbdA3Pj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 10:39:28 -0500
In-Reply-To: <1485708980-23468-6-git-send-email-tariqt@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan
> Sent: 29 January 2017 16:56
> From: Ariel Levkovich <lariel@mellanox.com>
> 
> This feature will allow the user to disable auto negotiation
> on the port for mlx4 devices while setting the speed is limited
> to 1GbE speeds.
> Other speeds will not be accepted in autoneg off mode.

What is the rationale behind this change?

When I was writing ethernet drivers it was always better to
leave autonegotiation enabled with restricted modes than to
fix the speed.

That ensures that far end is using the same mode.

This was particularly important for FDX v HDX at 10/100 speeds,
but I suspect it is equally relevant now.

	David
