From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] igb: fix link reporting when using sgmii
Date: Sat, 31 Jan 2009 00:53:48 -0800 (PST)
Message-ID: <20090131.005348.56799417.davem@davemloft.net>
References: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
	<20090131005425.1466.60907.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751506AbZAaIxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 03:53:51 -0500
In-Reply-To: <20090131005425.1466.60907.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 30 Jan 2009 16:54:25 -0800

> When using sgmii the link was not being properly passed up to the driver
> from the underlying link management functions.  This change corrects it so
> that get_link_status is cleared when a link has been found.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
