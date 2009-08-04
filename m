From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igbvf: Allow VF driver to correctly recognize
 failure to set mac
Date: Tue, 04 Aug 2009 11:47:30 -0700 (PDT)
Message-ID: <20090804.114730.215349771.davem@davemloft.net>
References: <20090804172103.23659.5847.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933149AbZHDSrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 14:47:21 -0400
In-Reply-To: <20090804172103.23659.5847.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 04 Aug 2009 10:21:04 -0700

> The VF driver was not correctly recognizing that it did not correctly set
> it's mac address.  As a result the VF driver was unable to receive network
> traffic until being unloaded and reloaded.  The issue was root caused to
> the fact that the CTS bit was not taken into account when checking for the
> request being NAKed.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
