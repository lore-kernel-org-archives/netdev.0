From: David Miller <davem@davemloft.net>
Subject: Re: igbvf: add new driver to support 82576 virtual functions
Date: Tue, 24 Mar 2009 23:38:43 -0700 (PDT)
Message-ID: <20090324.233843.61607506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752531AbZCYGi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:38:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This breaks the build:

drivers/net/igbvf/ethtool.c: In function 'igbvf_set_ringparam':
drivers/net/igbvf/ethtool.c:299: error: implicit declaration of function 'vmalloc'
drivers/net/igbvf/ethtool.c:299: warning: assignment makes pointer from integer without a cast
drivers/net/igbvf/ethtool.c:346: error: implicit declaration of function 'vfree'
