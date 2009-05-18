From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: set max desc to prevent total
 RSC packet size of 64K
Date: Mon, 18 May 2009 15:10:01 -0700 (PDT)
Message-ID: <20090518.151001.16071533.davem@davemloft.net>
References: <20090518065745.14864.86660.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752894AbZERWKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:10:04 -0400
In-Reply-To: <20090518065745.14864.86660.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 17 May 2009 23:57:47 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The performance of hardware RSC is greatly reduced if the total for max rsc
> descriptors multiplied by the buffer size is greater than 65535.  To
> prevent this we need to adjust the max rsc descriptors appropriately.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
