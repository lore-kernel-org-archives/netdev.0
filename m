From: David Miller <davem@davemloft.net>
Subject: Re: [net] igb: Workaround for i210 Errata 25: Slow System Clock
Date: Thu, 10 Jul 2014 01:48:41 -0700 (PDT)
Message-ID: <20140710.014841.946487810069344605.davem@davemloft.net>
References: <1404982035-12709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: todd.fujinaka@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaGJIsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:48:42 -0400
In-Reply-To: <1404982035-12709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 10 Jul 2014 01:47:15 -0700

> From: Todd Fujinaka <todd.fujinaka@intel.com>
> 
> On some devices, the internal PLL circuit occasionally provides the
> wrong clock frequency after power up. The probability of failure is less
> than one failure per 1000 power cycles. When the failure occurs, the
> internal clock frequency is around 1/20 of the correct frequency.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
