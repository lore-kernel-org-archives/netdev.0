From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: Add process name to WARN message when
 detecting Mutex contention
Date: Fri, 09 Jan 2009 23:07:29 -0800 (PST)
Message-ID: <20090109.230729.223833931.davem@davemloft.net>
References: <20090109020328.16029.47388.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, david.graham@intel.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbZAJHH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:07:29 -0500
In-Reply-To: <20090109020328.16029.47388.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 08 Jan 2009 18:03:29 -0800

> From: David Graham <david.graham@intel.com>
> 
> Adds process name of the current mutex holder to the WARN message output
> when the e1000e driver attempts to acquire the nvm_mutex and finds that
> it is already being held. With this patch the WARN message indicates
> both the process name of the current mutex holder and the process name of
> the attempted acquisition, which together will help to identify the
> contending codepaths.
> 
> Signed-off-by: David Graham <david.graham@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
