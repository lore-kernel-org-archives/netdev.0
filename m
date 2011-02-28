From: Jiri Pirko <jpirko@redhat.com>
Subject: [question] fcoe: bonding support
Date: Mon, 28 Feb 2011 13:29:58 +0100
Message-ID: <20110228122957.GB4043@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54300 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab1B1MaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 07:30:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Robert.

I wonder what's the meaning of the following code in fcoe_interface_setup():

        /* Do not support for bonding device */
        if ((netdev->priv_flags & IFF_MASTER_ALB) ||
            (netdev->priv_flags & IFF_SLAVE_INACTIVE) ||
            (netdev->priv_flags & IFF_MASTER_8023AD)) {
                FCOE_NETDEV_DBG(netdev, "Bonded interfaces not supported\n");
                return -EOPNOTSUPP;
        }

>From this I cannot understand if bonding is not supported at all or
only alb and 8023ad modes are not supported (leaving aside completely
bogus checking for IFF_SLAVE_INACTIVE).

How about to check IFF_BONDING only (in case bonding should not be
supported at all)

Thanks.

Jirka
