From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40e: Fix mismatching type for ioremap_len
Date: Thu, 05 Mar 2015 22:12:51 -0500 (EST)
Message-ID: <20150305.221251.796948917211617989.davem@davemloft.net>
References: <1425610955-11099-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbCFDMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:12:53 -0500
In-Reply-To: <1425610955-11099-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  5 Mar 2015 19:02:35 -0800

> As pointed out by Ben Hutchings, ioremap uses unsigned long as
> its parameter type, so we should be using that instead of u32
> or int.
> 
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
