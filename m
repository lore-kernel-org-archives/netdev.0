From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e/i40evf: set AQ count after memory allocation
Date: Wed, 07 Oct 2015 04:14:21 -0700 (PDT)
Message-ID: <20151007.041421.66427289560131994.davem@davemloft.net>
References: <1443917585-37687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbbJGK6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:58:36 -0400
In-Reply-To: <1443917585-37687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  3 Oct 2015 17:13:05 -0700

> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> The standard way to check if the AQ is enabled is to look at the
> count field. So we should only set this field after we have
> successfully allocated memory. To do otherwise is to incite
> panic among the populace.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
