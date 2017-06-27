From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Tue, 27 Jun 2017 15:40:46 -0400 (EDT)
Message-ID: <20170627.154046.2012864112666109026.davem@davemloft.net>
References: <20170625151953.GA7799@lunn.ch>
        <d5cd081c-9882-fce8-697c-2be062756962@mellanox.com>
        <20170626133439.GB2623@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galp@mellanox.com, netdev@vger.kernel.org, linville@tuxdriver.com,
        saeedm@mellanox.com, vidya@cumulusnetworks.com, jiri@mellanox.com,
        decot@googlers.com, kernel-team@fb.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdF0Tkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:40:49 -0400
In-Reply-To: <20170626133439.GB2623@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 26 Jun 2017 15:34:39 +0200

> I still fear this is going to be an ethtool call with only one user.

That is my fear as well.

We are also in a sort-of moratorium for adding new major ethtool
features until the conversion of ethtool over to netlink occurs.
