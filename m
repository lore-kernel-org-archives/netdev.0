From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] macsec: Fix header length if SCI is added if
 explicitly disabled
Date: Thu, 27 Oct 2016 16:21:53 -0400 (EDT)
Message-ID: <20161027.162153.2102538919251888970.davem@davemloft.net>
References: <77d75a4a-2307-6e3d-a4bb-7d7ff61bf3e8@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org
To: tobias@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33650 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933826AbcJ0UV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:21:58 -0400
In-Reply-To: <77d75a4a-2307-6e3d-a4bb-7d7ff61bf3e8@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias@strongswan.org>
Date: Mon, 24 Oct 2016 15:44:26 +0200

> Even if sending SCIs is explicitly disabled, the code that creates the
> Security Tag might still decide to add it (e.g. if multiple RX SCs are
> defined on the MACsec interface).
> But because the header length so far only depended on the configuration
> option the SCI overwrote the original frame's contents (EtherType and
> e.g. the beginning of the IP header) and if encrypted did not visibly
> end up in the packet, while the SC flag in the TCI field of the Security
> Tag was still set, resulting in invalid MACsec frames.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Tobias Brunner <tobias@strongswan.org>

Applied and queued up for -stable.
