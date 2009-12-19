From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v2 2/6] net: Add netif_num_vf function
Date: Fri, 18 Dec 2009 20:05:51 -0800 (PST)
Message-ID: <20091218.200551.39189145.davem@davemloft.net>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
	<20091218013410.4510.40263.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266AbZLSEFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:05:49 -0500
In-Reply-To: <20091218013410.4510.40263.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Well, first of all this won't build without CONFIG_PCI
defined.

Second of all, we're not putting PCI crap into netdevice.h

Create a generic device layer abstraction by which you can
fetch these values.

Thanks.
