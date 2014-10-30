From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx4_en: Extend checksum offloading by
 CHECKSUM COMPLETE
Date: Thu, 30 Oct 2014 11:22:19 -0700
Message-ID: <1414693339.14647.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	 <1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35187 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758593AbaJ3SWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 14:22:20 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so5611232pdb.35
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 11:22:20 -0700 (PDT)
In-Reply-To: <1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 18:06 +0200, Or Gerlitz wrote:
> From: Shani Michaeli <shanim@mellanox.com>
> 
> When processing received traffic, pass CHECKSUM_COMPLETE status to the
> stack, with calculated checksum for non TCP/UDP packets (such
> as GRE or ICMP).
> 
> Although the stack expects checksum which doesn't include the pseudo
> header, the HW adds it. To address that, we are subtracting the pseudo
> header checksum from the checksum value provided by the HW.
> 
> In the IPv6 case, we also compute/add the IP header checksum which
> is not added by the HW for such packets.
> 
> Cc: Jerry Chu <hkchu@google.com>
> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---


Awesome !
