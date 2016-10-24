From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 net] macsec: Fix header length if SCI is added if
 explicitly disabled
Date: Mon, 24 Oct 2016 16:50:24 +0200
Message-ID: <20161024145024.GA17050@bistromath.localdomain>
References: <77d75a4a-2307-6e3d-a4bb-7d7ff61bf3e8@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938646AbcJXOu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 10:50:28 -0400
Content-Disposition: inline
In-Reply-To: <77d75a4a-2307-6e3d-a4bb-7d7ff61bf3e8@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-10-24, 15:44:26 +0200, Tobias Brunner wrote:
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

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
