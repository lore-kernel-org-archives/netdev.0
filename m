From: David Miller <davem@davemloft.net>
Subject: Re: [net] igb: fix rtnl race in PM resume path
Date: Thu, 10 May 2012 22:45:12 -0400 (EDT)
Message-ID: <20120510.224512.1770094068726953877.davem@davemloft.net>
References: <1336700317-31929-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpoirier@suse.de, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073Ab2EKCpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 22:45:21 -0400
In-Reply-To: <1336700317-31929-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 10 May 2012 18:38:37 -0700

> From: Benjamin Poirier <bpoirier@suse.de>
> 
> Since the caller (PM resume code) is not the one holding rtnl, when taking the
> 'else' branch rtnl may be released at any moment, thereby defeating the whole
> purpose of this code block.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
