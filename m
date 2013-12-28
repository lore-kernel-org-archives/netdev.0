From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 02/16] i40e: Suppress HMC error to Interrupt
 message level
Date: Sat, 28 Dec 2013 01:11:07 -0500 (EST)
Message-ID: <20131228.011107.307499594588026836.davem@davemloft.net>
References: <1388200940-9113-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1388200940-9113-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, shannon.nelson@intel.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab3L1GLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:11:09 -0500
In-Reply-To: <1388200940-9113-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Dec 2013 19:22:06 -0800

> Prevent messages from stray HMC events, except at interrupt message
> level, and refactor HMC error handling.

I don't understand this commit message.  How is this change only
showing the HME event message "at interrupt message level".  It's
using plain dev_info() to report it in the new location too.
