From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/5] igb: rework igb_set_multi so that vfs are
 properly updated
Date: Sat, 21 Mar 2009 16:57:31 -0700 (PDT)
Message-ID: <20090321.165731.109977152.davem@davemloft.net>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
	<20090320101725.17663.72236.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38439
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754639AbZCUX5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 19:57:44 -0400
In-Reply-To: <20090320101725.17663.72236.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2009 03:17:25 -0700

> Currently if there are no multicast addresses programmed into the PF then
> the VFs cannot have their multicast filters reset.  This change makes it so
> the code path that updates vf multicast is always called along with the pf
> updates.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
