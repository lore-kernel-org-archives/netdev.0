From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: Fix opps when adding vlan
 bridge
Date: Fri, 16 Dec 2016 13:27:30 -0500 (EST)
Message-ID: <20161216.132730.1297195526327791354.davem@davemloft.net>
References: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758520AbcLPS1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:27:32 -0500
In-Reply-To: <1481486839-19502-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 11 Dec 2016 21:07:19 +0100

> A port is not necessarily assigned to a netdev. And a port does not
> need to be a member of a bridge. So when iterating over all ports,
> check before using the netdev and bridge_dev for a port. Otherwise we
> dereference a NULL pointer.
> 
> Fixes: da9c359e19f0 ("net: dsa: mv88e6xxx: check hardware VLAN in use")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
