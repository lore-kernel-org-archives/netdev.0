From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: Fix compiler warning about variable
 being used uninitialized
Date: Sun, 13 Dec 2009 19:20:29 -0800 (PST)
Message-ID: <20091213.192029.104053340.davem@davemloft.net>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932162AbZLNDU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:20:27 -0500
In-Reply-To: <20091212075120.10952.98484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Dec 2009 23:51:23 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> tc is still throwing a warning that is could be used
> uninitialized.  This fixes it.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

It's warning because it absolutely can be used uninitialized.

The two code blocks only handle two chip variants.  Why not
make what's happening here explicit by using a switch
statement and having a 'default' case?

Thanks.
