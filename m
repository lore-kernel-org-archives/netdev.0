From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igbvf: fix issue w/ mapped_as_page being left
 set after unmap
Date: Thu, 28 Jan 2010 05:56:51 -0800 (PST)
Message-ID: <20100128.055651.191151827.davem@davemloft.net>
References: <20100128013012.18801.97398.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182Ab0A1N4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 08:56:39 -0500
In-Reply-To: <20100128013012.18801.97398.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Jan 2010 17:30:39 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change fixes an issue in igbvf with mapped_as_page being left set
> after a page is unmapped which results in buffers which are mapped via map
> single being unmapped as page.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
