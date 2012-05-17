From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000: Prevent reset task killing itself.
Date: Thu, 17 May 2012 18:33:07 -0400 (EDT)
Message-ID: <20120517.183307.2184016629087404296.davem@davemloft.net>
References: <1337252690-29687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tushar.n.dave@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030224Ab2EQWdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 18:33:11 -0400
In-Reply-To: <1337252690-29687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 May 2012 04:04:50 -0700

> From: Tushar Dave <tushar.n.dave@intel.com>
> 
> Killing reset task while adapter is resetting causes deadlock.
> Only kill reset task if adapter is not resetting.
> Ref bug #43132 on bugzilla.kernel.org
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
