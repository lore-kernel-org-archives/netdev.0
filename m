From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/2][pull request] Intel Wired LAN Driver Updates
 2015-10-22
Date: Thu, 22 Oct 2015 19:02:43 -0700 (PDT)
Message-ID: <20151022.190243.1802700389473045990.davem@davemloft.net>
References: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbbJWBqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 21:46:17 -0400
In-Reply-To: <1445562953-47496-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 22 Oct 2015 18:15:51 -0700

> This series contains fixes to i40e only.
> 
> Jesse provides two small fixes for i40e, first fixes counters that were
> being displayed incorrectly due to indexing beyond the array of strings
> when printing stats.  Then fixed the fact that the driver was printing
> a message about not being able to assign VMDq because a lack of MSI-X
> vectors, when it was not true.  It was due to a line missing that
> initialized a variable.

Pulled, thanks Jeff.
