From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: pch_gbe: Fix TX RX descriptor accesses for big
 endian systems
Date: Wed, 7 Dec 2016 23:05:51 +0100
Message-ID: <20161207220551.GA5889@electric-eye.fr.zoreil.com>
References: <1481133534-26224-1-git-send-email-hassan.naveed@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Burton <paul.burton@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: Hassan Naveed <hassan.naveed@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33662 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932595AbcLGWGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 17:06:02 -0500
Content-Disposition: inline
In-Reply-To: <1481133534-26224-1-git-send-email-hassan.naveed@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hassan Naveed <hassan.naveed@imgtec.com> :
> Fix pch_gbe driver for ethernet operations for a big endian CPU.
> Values written to and read from transmit and receive descriptors
> in the pch_gbe driver are byte swapped from the perspective of a
> big endian CPU, since the ethernet controller always operates in
> little endian mode. Rectify this by appropriately byte swapping
> these descriptor field values in the driver software.

You should also use __le{16/32} types in struct pch_gbe_{rx/tx}_desc.

-- 
Ueimor
