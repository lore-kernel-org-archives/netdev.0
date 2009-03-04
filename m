From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] be2net: header files
Date: Tue, 03 Mar 2009 23:47:00 -0800 (PST)
Message-ID: <20090303.234700.198045916.davem@davemloft.net>
References: <1236087210.6013.39.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbZCDHrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 02:47:15 -0500
In-Reply-To: <1236087210.6013.39.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 03 Mar 2009 19:03:30 +0530

> +struct be_ctrl_info {
> +	u8 __iomem *csr;
> +	u8 __iomem *db;		/* Door Bell */
> +	u8 __iomem *pcicfg;	/* PCI config space */

Although these pointers are properly declared with the __iomem
marker, the code in some places fails to specify the __iomem
qualifier.

For example, be_mbox_db_ring(), be_mbox_db_ready_wait().

I am sure there are others.

If you check your driver's build with sparse it will warn about these
kinds of problems.
