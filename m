From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio: mux: make child bus walking more
 permissive and errors more verbose
Date: Sun, 04 Jun 2017 19:30:58 -0400 (EDT)
Message-ID: <20170604.193058.256838162791393085.davem@davemloft.net>
References: <1496259890-3719-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: jon.mason@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbdFDXbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 19:31:02 -0400
In-Reply-To: <1496259890-3719-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@broadcom.com>
Date: Wed, 31 May 2017 15:44:50 -0400

> If any errors are encountered while walking the device tree structure of
> the MDIO bus for children, the code may silently continue, silently
> exit, or throw an error and exit.  This make it difficult for device
> tree writers to know there is an error.  Also, it makes any error in a
> child entry of the MDIO bus be fatal for all entries.  Instead, we
> should provide verbose errors describing the error and then attempt to
> continue if it all possible.  Also, use of_mdio_parse_addr()
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Looks good.  Every conversion from break to continue properly gets rid
of the child_bus_node release, and this new behavior matches what was
discussed a few weeks ago.

Applied, thanks.
