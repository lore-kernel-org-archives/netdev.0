From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 2/2] net-next: mt7530: add nh and proto offsets to the ops
 struct
Date: Tue, 20 Jun 2017 15:54:39 +0200
Message-ID: <20170620135439.GA12383@lunn.ch>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620080655.7251-2-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57132 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751133AbdFTNy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 09:54:59 -0400
Content-Disposition: inline
In-Reply-To: <20170620080655.7251-2-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 10:06:55AM +0200, John Crispin wrote:
> The MT7530 inserts the 4 magic header in between the 802.3 address and
> protocol field. The patch defines these header such that the flow_disector
> can properly parse the packet and thus allows hashing to function properly.

This is to do with tagging, not the switch driver. The Marvell switch
driver can be used with two different tagging protocols.

So i would put these fields in the dsa_device_ops.

   Andrew
